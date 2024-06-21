import logger from '../logger/logger'; // Ensure the correct import path
import axios from 'axios';
import { extractYouTubeID } from './youtubeTranscript';

/**
 * Checks if the given URL is a YouTube video link.
 * @param {string} inputString - The URL to check.
 * @returns {boolean} - True if the URL is a YouTube video link, false otherwise.
 */
export function containsValidYoutubeUrl(inputString: string): string | null {
  const youtubeRegex =
    /https?:\/\/(www\.youtube\.com|m\.youtube\.com|youtube\.com|youtu\.be)\/[^\s]+/;
  const match = inputString.match(youtubeRegex);

  if (match) {
    const url = match[0];
    logger.info(`URL is a valid YouTube link format: ${url}`);
    return url;
  } else {
    logger.info(`No valid YouTube link found in input: ${inputString}`);
    return null;
  }
}

/**
 * Returns an array of YouTube thumbnail URLs for a given video ID.
 * @param {string} url - The YouTube video ID.
 * @returns {string[]} - An array of thumbnail URLs.
 */
export function getYouTubeThumbnailUrls(url: string): string[] {
  const videoId = extractYouTubeID(url);
  return [
    `https://img.youtube.com/vi/${videoId}/maxresdefault.jpg`,
    `https://img.youtube.com/vi/${videoId}/sddefault.jpg`,
    `https://img.youtube.com/vi/${videoId}/hqdefault.jpg`,
    `https://img.youtube.com/vi/${videoId}/mqdefault.jpg`,
    `https://img.youtube.com/vi/${videoId}/default.jpg`,
  ];
}

/**
 * Fetches an image from a list of URLs and returns it in Base64 format.
 * @param {string[]} imageUrls - An array of image URLs.
 * @returns {Promise<string>} - A promise that resolves to the Base64-encoded image.
 * @throws {Error} - Throws an error if all attempts to fetch the image fail.
 */
export async function getBase64ImageFromUrl(
  imageUrls: string[]
): Promise<string> {
  for (const imageUrl of imageUrls) {
    try {
      const response = await axios.get(imageUrl, {
        responseType: 'arraybuffer',
      });
      if (response.status === 200) {
        const base64 = Buffer.from(response.data, 'binary').toString('base64');
        return base64;
      }
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (error: any) {
      if (error.response && error.response.status === 404) {
        // If the image is not found, try the next URL
        continue;
      } else {
        throw new Error(`Failed to fetch image: ${error.message}`);
      }
    }
  }
  throw new Error('Failed to fetch image: All attempts failed');
}
