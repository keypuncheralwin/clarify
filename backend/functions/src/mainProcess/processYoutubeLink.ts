import axios from 'axios';
import { Response } from 'express';
import logger from '../logger/logger';
import {
  getBase64ImageFromUrl,
  getYouTubeThumbnailUrls,
} from '../utils/youtubeValidation';
import { extractJson } from '../utils/general';
import {
  extractYouTubeID,
  fetchTranscript,
  YoutubeTranscriptError,
} from '../utils/youtubeTranscript';
import { generateClickbaitYouTubePrompt } from '../constants/youtube';
import { safetySettings } from '../constants/gemini';

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

    const payload = {
      contents: [
        {
          parts: [
            { text: prompt },
            {
              inlineData: {
                mimeType: 'image/jpeg',
                data: thumbnailBase64,
              },
            },
          ],
        },
      ],
      safetySettings,
    };

    const apiUrl = `https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=${apiKey}`;
    const headers = {
      'Content-Type': 'application/json',
    };

    const result = await axios.post(apiUrl, payload, { headers });
    const data = result.data.candidates[0].content.parts
      .map((part: { text: string }) => part.text)
      .join(' ');

    const response = extractJson(data);
    logger.info('Response received from AI model', { response });
    res.json({ response });
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
