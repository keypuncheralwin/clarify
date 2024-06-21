import logger from '../logger/logger';

/**
 * Extracts the original web URL if it's wrapped within another URL (e.g., AMP).
 * If the URL does not meet specific cases, returns the original URL.
 *
 * @param {string} url - The URL to perform extra checks on.
 * @returns {string} The extracted web URL or the original URL if cases do not match.
 */
export function specialCasesCheck(url: string): string {
  logger.info(`Checking URL for special cases: ${url}`);
  try {
    const parsedUrl = new URL(url);
    const host = parsedUrl.host;

    if (host.includes('cdn.ampproject.org')) {
      logger.info(`Extracting original URL from AMP URL: ${url}`);
      return extractFromAmpUrl(parsedUrl);
    }

    // Add more special cases here as needed
    // if (host.includes('some-other-case.com')) {
    //     return extractFromOtherCase(parsedUrl);
    // }

    // Return the original URL if no special cases match
    return url;
  } catch (error) {
    logger.error('URL failed special cases check:', error);
    // Return the original URL in case of an error
    return url;
  }
}

/**
 * Extracts the original web URL from an AMP URL.
 * Validates the URL segments to ensure correct extraction.
 *
 * @param {URL} url - The parsed AMP URL.
 * @returns {string} The extracted web URL.
 */
function extractFromAmpUrl(url: URL): string {
  const pathSegments = url.pathname.split('/');
  const vIndex = pathSegments.indexOf('v');

  // Validate if 'v' exists and there are enough segments after 'v'
  if (vIndex === -1 || vIndex + 2 >= pathSegments.length) {
    logger.warn('Invalid AMP URL format.');
    return url.toString();
  }

  const startIndex = vIndex + 2; // Find the index after 'v' and 's'
  const extractedUrlSegments = pathSegments.slice(startIndex);

  // Validate if extracted segments form a valid URL
  if (extractedUrlSegments.length === 0 || !extractedUrlSegments[0]) {
    logger.warn('Invalid extracted URL segments.');
    return url.toString();
  }

  const extractedUrl = 'https://' + extractedUrlSegments.join('/');
  return extractedUrl;
}

// Example function for another special case
/**
 * Extracts the original web URL from another special case URL.
 *
 * @param {URL} url - The parsed special case URL.
 * @returns {string} The extracted web URL.
 */
// function extractFromOtherCase(url: URL): string {
//     // Implement extraction logic for another special case
//     return url.toString();
// }
