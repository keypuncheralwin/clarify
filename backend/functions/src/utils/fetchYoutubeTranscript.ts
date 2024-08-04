import { YoutubeTranscript } from 'youtube-transcript';
import parse from 'node-html-parser';
import logger from '../logger/logger';
import { saveFailedToAnalyseLink } from '../dbMethods/saveFailedToAnalyseLink';

const USER_AGENT =
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36,gzip(gfe)';

async function fetchVideoTitle(videoId: string): Promise<string | null> {
  try {
    const videoPage = await fetch(
      `https://www.youtube.com/watch?v=${videoId}`,
      {
        headers: {
          'User-Agent': USER_AGENT,
        },
      }
    ).then((res) => res.text());

    const html = parse(videoPage);
    const videoTitle = html.querySelector('title')?.text || 'Unknown title';

    if (videoTitle === 'Unknown title') {
      saveFailedToAnalyseLink(videoId, 'Unknown title');
      return null;
    }

    return videoTitle;
  } catch (error) {
    logger.error('Error fetching video title:', videoId, error);
    saveFailedToAnalyseLink(videoId, 'Error fetching video title ' + error);
    return null;
  }
}

async function getFullTranscript(
  videoId: string
): Promise<{ transcript: string | null; title: string | null }> {
  try {
    const [transcript, title] = await Promise.all([
      YoutubeTranscript.fetchTranscript(videoId),
      fetchVideoTitle(videoId),
    ]);

    const fullTranscript: string = transcript
      .map((segment) => segment.text)
      .join(' ');

    if (fullTranscript.trim() === '' || !title) {
      logger.error('Transcript or title is empty:', videoId);
      saveFailedToAnalyseLink(videoId, 'Transcript or title is empty');
      return { transcript: null, title: null };
    }

    logger.info('Youtube transcript and title fetched successfully:');
    return { transcript: fullTranscript, title };
  } catch (error) {
    logger.error('Error fetching transcript or title:', videoId, error);
    saveFailedToAnalyseLink(
      videoId,
      'Error fetching transcript or title ' + error
    );
    return { transcript: null, title: null };
  }
}

export default getFullTranscript;
