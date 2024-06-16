import parse, { HTMLElement } from 'node-html-parser';
import logger from '../logger/logger';

const USER_AGENT =
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36,gzip(gfe)';

interface TranscriptEntry {
  text: string;
  offset: number;
  duration: number;
}

interface FetchTranscriptConfig {
  lang?: string;
}

interface TranscriptResult {
  videoTitle: string;
  transcript: TranscriptEntry[];
}

class YoutubeTranscriptError extends Error {
  constructor(message: string) {
    super(`[YoutubeTranscript] ${message}`);
  }
}

async function fetchTranscript(
  videoId: string,
  config: FetchTranscriptConfig = {}
): Promise<TranscriptResult> {
  logger.info('Fetching transcript for video ID:', videoId);
  const identifier = extractYouTubeID(videoId);
  const lang = config.lang ?? 'en';
  try {
    const videoPage = await fetch(
      `https://www.youtube.com/watch?v=${identifier}`,
      {
        headers: {
          'User-Agent': USER_AGENT,
        },
      }
    ).then((res) => res.text());

    const html = parse(videoPage);
    const videoTitle = html.querySelector('title')?.text || 'Unknown title';
    logger.info('Fetched video title:', videoTitle);

    const transcriptUrl = parseTranscriptEndpoint(html, lang);

    if (!transcriptUrl)
      throw new YoutubeTranscriptError(
        'Failed to locate a transcript for this video!'
      );

    // Result is hopefully some XML.
    const transcriptXML = await fetch(transcriptUrl)
      .then((res) => res.text())
      .then((xml) => parse(xml));

    const chunks = transcriptXML.getElementsByTagName('text');

    const transcriptions: TranscriptEntry[] = [];
    for (const chunk of chunks) {
      const [offset, duration] = chunk.rawAttrs.split(' ');
      transcriptions.push({
        text: chunk.text,
        offset: convertToMs(offset),
        duration: convertToMs(duration),
      });
    }
    logger.info('Fetched transcript for video ID:', videoId);
    return { videoTitle, transcript: transcriptions };
  } catch (e) {
    logger.error('Error fetching transcript:', e);
    throw new YoutubeTranscriptError(
      e instanceof Error ? e.message : String(e)
    );
  }
}

function convertToMs(text: string): number {
  const float = parseFloat(text.split('=')[1].replace(/"/g, '')) * 1000;
  return Math.round(float);
}

function parseTranscriptEndpoint(
  document: HTMLElement,
  langCode: string
): string | null {
  try {
    // Get all script tags on document page
    const scripts = document.getElementsByTagName('script');

    // find the player data script.
    const playerScript = scripts.find((script) =>
      script.textContent.includes('var ytInitialPlayerResponse = {')
    );

    const dataString =
      playerScript?.textContent
        ?.split('var ytInitialPlayerResponse = ')?.[1] //get the start of the object {....
        ?.split('};')?.[0] + // chunk off any code after object closure.
      '}'; // add back that curly brace we just cut.

    const data = JSON.parse(dataString.trim()); // Attempt a JSON parse
    const availableCaptions =
      data?.captions?.playerCaptionsTracklistRenderer?.captionTracks || [];

    // If languageCode was specified then search for its code, otherwise get the first.
    let captionTrack = availableCaptions?.[0];
    if (langCode) {
      captionTrack =
        availableCaptions.find((track: any) =>
          track.languageCode.includes(langCode)
        ) ?? availableCaptions?.[0];
    }

    logger.info('Parsed transcript endpoint for language code:', langCode);
    return captionTrack?.baseUrl || null;
  } catch (e) {
    logger.error(
      `parseTranscriptEndpoint Error: ${
        e instanceof Error ? e.message : String(e)
      }`
    );
    return null;
  }
}

function extractYouTubeID(urlOrID: string): string | null {
  // Regular expression for YouTube ID format
  const regExpID = /^[a-zA-Z0-9_-]{11}$/;

  // Check if the input is a YouTube ID
  if (regExpID.test(urlOrID)) {
    return urlOrID;
  }

  // Regular expression for standard YouTube links
  const regExpStandard = /youtube\.com\/watch\?v=([a-zA-Z0-9_-]+)/;

  // Regular expression for YouTube Shorts links
  const regExpShorts = /youtube\.com\/shorts\/([a-zA-Z0-9_-]+)/;

  // Check for standard YouTube link
  const matchStandard = urlOrID.match(regExpStandard);
  if (matchStandard) {
    return matchStandard[1];
  }

  // Check for YouTube Shorts link
  const matchShorts = urlOrID.match(regExpShorts);
  if (matchShorts) {
    return matchShorts[1];
  }

  // Return null if no match is found
  logger.warn('No valid YouTube ID found in:', urlOrID);
  return null;
}

export { fetchTranscript, YoutubeTranscriptError, extractYouTubeID };
