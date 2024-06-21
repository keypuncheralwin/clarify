import axios from 'axios';
import { Article } from '../types/article';
import cheerio from 'cheerio';
import logger from '../logger/logger';

export default async function fetchArticle(
  url: string
): Promise<Article | null> {
  try {
    const { data: html } = await axios.get(url, {
      headers: {
        'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      },
    });

    const $ = cheerio.load(html);

    const title =
      $('meta[property="og:title"]').attr('content') ||
      $('meta[name="twitter:title"]').attr('content') ||
      $('head > title').text() ||
      $('meta[name="title"]').attr('content');

    const description =
      $('meta[name="description"]').attr('content') ||
      $('meta[property="og:description"]').attr('content') ||
      $('meta[name="twitter:description"]').attr('content');

    const content = $('article').text() || $('body').text();

    if (!title && !content) {
      logger.warn(`No article found at URL: ${url}`);
      return null;
    }

    logger.info(`Article fetched successfully from URL: ${url}`, {
      title,
      description,
    });

    return {
      title: (title as string).trim(),
      subtitle: description?.trim() || '',
      content: (content as string).trim(),
    };
  } catch (error) {
    logger.error('Error fetching article:', error);
    return null;
  }
}
