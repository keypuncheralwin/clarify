import { Response } from 'express';
import logger from '../logger/logger';
import {
  getBase64ImageFromUrl,
  getYouTubeThumbnailUrls,
} from '../utils/youtubeValidation';
import { getChatResponse, processResponse } from '../utils/general';
import {
  extractYouTubeID,
  fetchTranscript,
  YoutubeTranscriptError,
} from '../utils/youtubeTranscript';
import {
  clickbaitCriteriaForYouTube,
  generateClickbaitYouTubePrompt,
} from '../constants/youtube';
import { safetySettings, generationConfig } from '../constants/gemini';
import {
  GoogleGenerativeAI,
  FileDataPart,
  TextPart,
} from '@google/generative-ai';
import { GoogleAIFileManager } from '@google/generative-ai/files';
import fs from 'fs';
import path from 'path';
import os from 'os';

/**
 * Process the YouTube link to determine if the video is clickbait.
 * @param url - The YouTube video URL.
 * @param res - The Express response object.
 * @param apiKey - The gemini api key.
 * @returns {Promise<void>} - A promise that resolves when the processing is complete.
 */
async function processYouTubeLink(
  url: string,
  res: Response,
  apiKey: string
): Promise<void> {
  if (!extractYouTubeID(url)) {
    res.status(400).json({ error: 'Unable to extract video ID from URL' });
    return;
  }

  try {
    // Fetch transcript using custom function
    const { videoTitle, transcript } = await fetchTranscript(url);
    const transcriptText = transcript.map((entry) => entry.text).join(' ');

    // Fetch and encode thumbnail image
    const thumbnailUrls = getYouTubeThumbnailUrls(url);
    const thumbnailBase64 = await getBase64ImageFromUrl(thumbnailUrls);

    const prompt = generateClickbaitYouTubePrompt(videoTitle, transcriptText);

    // Initialize the Gemini model and start a chat session
    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({
      model: 'gemini-1.5-flash',
      systemInstruction: clickbaitCriteriaForYouTube,
    });

    const fileManager = new GoogleAIFileManager(apiKey);

    // Convert base64 string to buffer
    const buffer = Buffer.from(thumbnailBase64, 'base64');

    // Create a temporary file for the buffer
    const tmpFilePath = path.join(os.tmpdir(), 'thumbnail.jpg');
    fs.writeFileSync(tmpFilePath, buffer);

    // Upload the temporary file
    const uploadResult = await fileManager.uploadFile(tmpFilePath, {
      mimeType: 'image/jpeg',
      displayName: 'thumbnail.jpg',
    });

    // Remove the temporary file after upload
    fs.unlinkSync(tmpFilePath);

    const fileUri = uploadResult.file.uri;

    const chatSession = model.startChat({
      safetySettings,
      generationConfig,
    });

    // Create the message with the image URI and prompt
    const messageParts: (TextPart | FileDataPart)[] = [
      { text: prompt },
      {
        fileData: {
          mimeType: 'image/jpeg',
          fileUri,
        },
      },
    ];

    let response = await getChatResponse(messageParts, chatSession);

    if (response) {
      response = processResponse(response, 'youtube', url);
      logger.info(`Received response: ${JSON.stringify(response)}`);
      res.json({ response });
    } else {
      logger.error('No response received from the chat session');
      res.status(500).send('Internal Server Error');
    }
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
  } catch (error: any) {
    if (error instanceof YoutubeTranscriptError) {
      logger.error('Transcript fetch error', { message: error.message }, error);
      res
        .status(400)
        .json({ error: 'Transcript fetch error', details: error.message });
    } else if (error.response && error.response.data) {
      logger.error(
        'Video not supported',
        {
          details: error.response.data,
        },
        error
      );
      res.status(400).json({
        error:
          'Content was blocked due to safety concerns. Please try with a different input.',
        details: error.response.data,
      });
    } else {
      logger.error('Error processing YouTube link', error);
      res.status(500).json({
        error: 'Failed to process YouTube link',
        details: error.message,
      });
    }
  }
}

export default processYouTubeLink;
