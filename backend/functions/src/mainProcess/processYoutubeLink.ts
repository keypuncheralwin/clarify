import { Response } from 'express';
import logger from '../logger/logger';
import {
  getBase64ImageFromUrl,
  getYouTubeThumbnailUrls,
} from '../utils/youtubeValidation';
import {
  getChatResponse,
  getYouTubeUrl,
  hashUrl,
  processResponse,
} from '../utils/general';
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
import { firestore } from 'firebase-admin';
import { saveUrlToUserHistory } from '../dbMethods/saveUrlToUserHistory';
import { saveAnalysedLink } from '../dbMethods/saveAnalysedLink';
import { saveFailedToAnalyseLink } from '../dbMethods/saveFailedToAnalyseLink';
import { getAnalysedLinkIfExists } from '../dbMethods/getAnalysedLinkIfExists';
import { AnalysisResult } from '../types/general';
import { saveUrlToDeviceHistory } from '../dbMethods/saveUrlToDeviceHistory';

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
  apiKey: string,
  deviceId: string,
  userUuid?: string
): Promise<void> {
  const db = firestore();
  const youtubeId = extractYouTubeID(url);
  if (!youtubeId) {
    saveFailedToAnalyseLink(url, 'Not able to extract YouTube ID from URL');
    res.status(400).json({ error: 'Unable to extract video ID from URL' });
    return;
  }
  // We have to do this since YouTube can have multiple url variations for the same video
  // This way we make sure that the video is only saved once
  const finalUrl = getYouTubeUrl(youtubeId);
  const hashedUrl = hashUrl(finalUrl);

  let response = await getAnalysedLinkIfExists(hashedUrl, db);

  if (response) {
    if (userUuid) {
      response = await saveUrlToUserHistory(hashedUrl, db, userUuid, response);
    } else {
      response = await saveUrlToDeviceHistory(
        hashedUrl,
        db,
        deviceId,
        response
      );
    }
    const analysisResult: AnalysisResult = {
      status: 'success',
      data: response,
    };
    res.json(analysisResult);
    return;
  }

  try {
    // Fetch transcript using custom function
    const { videoTitle, transcript } = await fetchTranscript(finalUrl);
    const transcriptText = transcript.map((entry) => entry.text).join(' ');

    // Fetch and encode thumbnail image
    const thumbnailUrls = getYouTubeThumbnailUrls(finalUrl);
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

    const aiResponse = await getChatResponse(messageParts, chatSession);

    if (aiResponse) {
      const processedAIResponse = processResponse(
        aiResponse,
        'youtube',
        finalUrl
      );
      response = await saveAnalysedLink(hashedUrl, db, processedAIResponse);
      if (userUuid) {
        response = await saveUrlToUserHistory(
          hashedUrl,
          db,
          userUuid,
          response
        );
      } else {
        response = await saveUrlToDeviceHistory(
          hashedUrl,
          db,
          deviceId,
          response
        );
      }
      logger.info(`Received response: ${JSON.stringify(response)}`);
      const analysisResult: AnalysisResult = {
        status: 'success',
        data: response,
      };
      res.json(analysisResult);
    } else {
      logger.error('No response received from the AI chat session');
      saveFailedToAnalyseLink(
        finalUrl,
        'No response received from the AI chat session'
      );
      const analysisResult: AnalysisResult = {
        status: 'error',
        error: {
          code: 500,
          message: 'Internal Server Error',
        },
      };
      res.status(500).json(analysisResult);
    }
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
  } catch (error: any) {
    if (error instanceof YoutubeTranscriptError) {
      logger.error('Transcript fetch error', { message: error.message }, error);
      saveFailedToAnalyseLink(finalUrl, 'Unable to fetch video transcript');
      const analysisResult: AnalysisResult = {
        status: 'error',
        error: {
          code: 400,
          message: 'Transcript fetch error',
        },
      };
      res.status(400).json(analysisResult);
    } else if (error.response && error.response.data) {
      logger.error(
        'Video not supported',
        {
          details: error.response.data,
        },
        error
      );
      saveFailedToAnalyseLink(finalUrl, 'Video not supported');
      const analysisResult: AnalysisResult = {
        status: 'error',
        error: {
          code: 400,
          message:
            'Content was blocked due to safety concerns. Please try with a different input.',
        },
      };
      res.status(400).json(analysisResult);
    } else {
      logger.error('Error processing YouTube link', error);
      saveFailedToAnalyseLink(finalUrl, 'Error processing YouTube link');
      const analysisResult: AnalysisResult = {
        status: 'error',
        error: {
          code: 500,
          message: 'Failed to process YouTube link',
        },
      };
      res.status(500).json(analysisResult);
    }
  }
}

export default processYouTubeLink;
