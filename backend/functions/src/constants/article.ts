const clickbaitArticleCriteria = `
  When evaluating whether the title is clickbait, please consider the following criteria:
  1. Does the title exaggerate or sensationalize the content to attract clicks?
  2. Does the title use misleading or ambiguous language to create curiosity?
  3. Does the title promise more than what the article delivers?
  4. The title can use emotionally charged words or phrases or imagery to provoke a reaction as 
  long as the article backs up the claims in which case the article is not clickbait.
`;

export const generateClickbaitArticlePrompt = (
  title: string,
  subtitle: string,
  content: string
): string => {
  return `
      Here is an article scraped from the internet. It may include unwanted text tags or irrelevant content. Please ignore any such unwanted text/tags. Also, can you clean up the title if you think it includes unnecessary words that seem to be added on to the title.
  
      Title: ${title}
      Subtitle: ${subtitle}
      Content: ${content}
  
      ${clickbaitArticleCriteria}
  
      1. Based on these criteria, is the title clickbait? If so, explain why briefly.
      2. Provide a brief summary of the article content.
      3. Clean up the title if it includes unnecessary words that seem to be added to the title.
  
      Please return the information in the following JSON format:
      {
          title: string,
          isClickBait: boolean,
          explanation: string,
          summary: string
      }
    `;
};
