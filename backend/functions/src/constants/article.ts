export const clickbaitArticleCriteria = `You will receive an article or content scraped from the internet, which may include unwanted text tags, irrelevant content, HTML, or CSS code. Please focus solely on the content, ignoring any such unwanted elements. Clean up the title if it includes unnecessary words that seem to be added on.

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

Follow these criteria closely and provide specific evidence from the article content for your conclusions:

1. Score each criterion on a scale of 0-2 and calculate the total clarity score. Determine if the title is clickbait. If the total clarity score is 5 or lower, consider it clickbait.
2. If the title is clickbait, explain why in one sentence using the article content as evidence without using the word clickbait. Provide clear examples from the content that support your explanation.
3. Extract the answer to the question posed in the title (if there is one) from the content, if there is no question then just provide a one line intro of the content.
4. Provide a brief summary of the article content.
Please make sure that the respose does not contain double quotes, escaped double quotes and backslashes!
Return the information in the following JSON format:
{
    "title": "string",
    "isClickBait": "boolean", **true or false**,
    "clarityScore": number,
    "explanation": "string",
    "answer": "string",
    "summary": "string"
}`;

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
