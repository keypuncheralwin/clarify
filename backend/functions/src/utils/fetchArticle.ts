import { Article } from '../types/article';
import logger from '../logger/logger';
import { extract } from '@extractus/article-extractor';

export default async function fetchArticle(
  url: string
): Promise<Article | null> {
  const article = await extract(url);
  if (!article?.title || !article?.content) {
    logger.warn(`No article found at URL: ${url}`);
    return null;
  }
  logger.info(`Article extracted successfully`);
  logger.info(`Title: ${article.title}`);
  const truncatedContent =
    article.content.length > 100
      ? `${article.content.slice(0, 100)}...`
      : article.content;
  logger.info(`Content: ${truncatedContent}`);
  return {
    title: article.title,
    subtitle: article.description || '',
    content: article.content,
  };
}
