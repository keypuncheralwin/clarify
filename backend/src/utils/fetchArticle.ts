import axios from 'axios';
import { Article } from '../types/article';
import cheerio from 'cheerio';
import logger from '../logger/logger';

export default async function fetchArticle(
  url: string
): Promise<Article | null> {
  try {
    const { data } = await axios.get(url, {
      headers: {
        'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      },
    });

    const $ = cheerio.load(data);

    const title = $('title').text();
    const subtitle = $('h2').first().text();
    let content = '';
    $('p').each((i, elem) => {
      content += $(elem).text() + '\n';
    });

    if (!title && !content) {
      logger.warn(`No article found at URL: ${url}`);
      return null;
    }

    logger.info(`Article fetched successfully from URL: ${url}`, {
      title,
      subtitle,
    });

    return { title, subtitle, content };
  } catch (error) {
    logger.error('Error fetching article:', error);
    return null;
  }
}
