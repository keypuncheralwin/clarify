import { saveFailedToAnalyseLink } from '../dbMethods/saveFailedToAnalyseLink';
import logger from '../logger/logger';

/**
 * Extracts and validates a URL from a string, handling Google redirect URLs if present.
 * @param {string} inputString - The input string that may contain a URL.
 * @returns {Promise<string | null>} - A promise that resolves to the valid URL or null if no valid URL is found.
 */
export default async function extractValidUrl(
  input: string
): Promise<string | null> {
  // Regular expression to match URLs
  const urlPattern = /https?:\/\/[^\s/$.?#].[^\s]*/g;
  const urls = input.match(urlPattern);

  if (urls && urls.length > 0) {
    let lastUrl = urls[urls.length - 1];

    // Check if it's a Google redirect URL
    if (lastUrl.includes('https://www.google.com/url')) {
      const urlParams = new URL(lastUrl).searchParams;
      const redirectedUrl = urlParams.get('url');
      if (redirectedUrl) {
        lastUrl = redirectedUrl;
      }
    }

    // Sanitize the URL
    try {
      // Use the URL constructor to parse and reassemble the URL
      const parsedUrl = new URL(lastUrl);

      // Encode the URL components to ensure special characters are handled
      const sanitisedUrl = encodeURI(parsedUrl.href);

      return sanitisedUrl;
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (error: any) {
      // If the URL is invalid, handle the error appropriately
      logger.error('Invalid URL:', error);
      saveFailedToAnalyseLink(input, `Invalid URL: ${error?.message}`);
      return null;
    }
  }

  // Return null if no valid URL is found
  saveFailedToAnalyseLink(input, `Invalid URL`);
  return null;
}
