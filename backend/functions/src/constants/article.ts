const clickbaitArticleCriteria = `
  When evaluating whether the title is clickbait, please consider the following criteria. Each criterion should be scored on a scale of 0-2:
  - **0**: Does not apply.
  - **1**: Partially applies.
  - **2**: Fully applies.

  1. Does the title exaggerate or sensationalize the content to attract clicks?
     - Look for words or phrases that seem overly dramatic or extreme compared to the article content.

  2. Does the title use misleading or ambiguous language to create curiosity?
     - Identify if the title uses vague language that could mean multiple things, prompting curiosity without providing clarity.

  3. Does the title promise more than what the article delivers?
     - Check if the title suggests information, results, or content that the article fails to provide.

  4. The title can use emotionally charged words or phrases or imagery to provoke a reaction as long as the article backs up the claims.
     - Ensure that any strong emotional appeal in the title is justified by the article content.

  5. If the title poses a question, it is not clickbait if the article answers the question.

  Calculate the total score based on the above criteria. If the total score is 5 or higher out of 10, consider the title clickbait. Otherwise, it is not clickbait.

  Please follow these criteria closely and provide specific evidence from the article content for your conclusions.
`;

export const generateClickbaitArticlePrompt = (
  title: string,
  subtitle: string,
  content: string
): string => {
  return `
      Here is an article scraped from the internet. It may include unwanted text tags or irrelevant content. Please ignore any such unwanted text/tags. Also, can you clean up the title if you think it includes unnecessary words that seem to be added on to the title.
      it may include html or css code, please ignore them and focus solely on the content. 

  
      Title: ${title}
      Subtitle: ${subtitle}
      Content: ${content}
  
      ${clickbaitArticleCriteria}
  
      Please address the following questions:
  
      1. Based on the above criteria, score each criteria on a scale of 0-2 and calculate the total score. Is the title clickbait? If the total score is 5 or higher, consider it clickbait. 
      2. If the title is clickbait Explain why in one sentence using the article content as evidence but don't use the word clickbait. Provide clear examples from the content that support your explanation.
      3. Extract the answer to the question posed in the title (if there is one) from the article content. 
      4. Provide a brief summary of the article content.
      Return the information in the following JSON format:
      {
          "title": "string",
          "isClickBait": "boolean",
          "totalScore": number,
          "explanation": "string",
          "answer": "string",
          "summary": "string"
      }
    `;
};
