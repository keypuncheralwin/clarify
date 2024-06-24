const clickbaitArticleCriteria = `I will be providing you with an article scraped from the internet. It may include unwanted text tags or irrelevant content. Please ignore any such unwanted text/tags. Also, can you clean up the title if you think it includes unnecessary words that seem to be added on to the title.
  It may include HTML or CSS code, please ignore them and focus solely on the content. I will be providing you with the title, subtitle, and content of the article.
  When evaluating whether the title is clickbait, please consider the following criteria. Each criterion should be scored on a scale of 0-2:
  - **0**: Fully applies (indicating clickbait).
  - **1**: Partially applies.
  - **2**: Does not apply (indicating clarity).

  1. Does the title exaggerate or sensationalize the content to attract clicks?
     - Look for words or phrases that seem overly dramatic or extreme compared to the article content.

  2. Does the title use misleading or ambiguous language to create curiosity?
     - Identify if the title uses vague language that could mean multiple things, prompting curiosity without providing clarity.

  3. Does the title promise more than what the article delivers?
     - Check if the title suggests information, results, or content that the article fails to provide.

  4. The title can use emotionally charged words or phrases or imagery to provoke a reaction as long as the article backs up the claims.
     - Ensure that any strong emotional appeal in the title is justified by the article content.

  5. If the title poses a question, it is not clickbait if the article answers the question.

  Calculate the total clarity score based on the above criteria. If the total clarity score is 5 or lower out of 10, consider the title clickbait. Otherwise, it is not clickbait.

  Please follow these criteria closely and provide specific evidence from the article content for your conclusions.

      1. Based on the above criteria, score each criterion on a scale of 0-2 and calculate the total clarity score. Is the title clickbait? If the total clarity score is 5 or lower, consider it clickbait.
      2. If the title is clickbait, explain why in one sentence using the article content as evidence but don't use the word clickbait. Provide clear examples from the content that support your explanation.
      3. Extract the answer to the question posed in the title (if there is one) from the article content.
      4. Provide a brief summary of the article content.
      Return the information in the following JSON format:
      {
          "title": "string",
          "isClickBait": "boolean", **true or false**,
          "clarityScore": number,
          "explanation": "string",
          "answer": "string",
          "summary": "string"
      }
`;

export const generateClickbaitArticlePrompt = (
  title: string,
  subtitle: string,
  content: string
): string => {
  return `
      Title: ${title}
      Subtitle: ${subtitle}
      Content: ${content}
    `;
};

export const clarityScoreDefinitionArticle =
  "The clarity score is a measure from 0 to 10 indicating how clear and accurate the title is, with higher scores indicating greater clarity and accuracy. The reason behind this article's clarity score: \n";

export const geminiArticleContext = [
  {
    role: 'user',
    parts: [
      {
        text: clickbaitArticleCriteria,
      },
    ],
  },
];
