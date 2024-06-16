import axios from 'axios';
import { URL } from 'url';
import logger from '../logger/logger'; // Ensure the correct import path

/**
 * Extracts and validates a URL from a string.
 * @param {string} inputString - The input string that may contain a URL.
 * @returns {Promise<string | null>} - A promise that resolves to the valid URL or null if no valid URL is found.
 */
export default async function extractValidUrl(
  inputString: string
): Promise<string | null> {
  logger.info(`Extracting URL from input string: ${inputString}`);

  // Regex to match URLs
  const urlRegex = /(https?:\/\/[^\s]+|www\.[^\s]+)/g;

  // Extract URLs from the string
  const urls = inputString.match(urlRegex);

  if (!urls || urls.length === 0) {
    logger.warn('No URLs found in the input string');
    return null;
  }

  // Check if the URL is valid
  for (let i = urls.length - 1; i >= 0; i--) {
    let currentUrl = urls[i];

    // Ensure the URL starts with http or https
    if (!currentUrl.startsWith('http')) {
      currentUrl = 'http://' + currentUrl;
    }

    try {
      const decodedUrl = decodeURIComponent(currentUrl);
      const urlObj = new URL(decodedUrl);

      if (urlObj.hostname === 'www.google.com' && urlObj.pathname === '/url') {
        // If it's a Google redirect URL, extract the 'url' parameter
        const actualUrl = urlObj.searchParams.get('url');
        if (actualUrl) {
          logger.info(`Extracted URL from Google redirect: ${actualUrl}`);
          return decodeURIComponent(actualUrl);
        }
      } else {
        await axios.get(decodedUrl, { maxRedirects: 0 });

        // If we get here, the URL is valid and there's no redirect
        logger.info(`Valid URL found: ${decodedUrl}`);
        return decodedUrl;
      }
    } catch (error: any) {
      logger.error(`Error validating URL: ${inputString}`, error);

      if (
        error.response &&
        (error.response.status === 301 || error.response.status === 302)
      ) {
        // Handle redirect
        const redirectUrl = error.response.headers.location;
        if (redirectUrl) {
          const resolvedUrl = redirectUrl.startsWith('http')
            ? redirectUrl
            : new URL(redirectUrl, currentUrl).href;
          logger.info(`Redirect URL resolved to: ${resolvedUrl}`);
          return resolvedUrl;
        }
      }
    }
  }

  logger.warn('No valid URLs found after validation');
  return null;
}
