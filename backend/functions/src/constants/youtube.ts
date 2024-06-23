const clickbaitCriteriaForYouTube = `
  When evaluating whether the YouTube video thumbnail or title is clickbait, please consider the following criteria. Each criterion should be scored on a scale of 0-2:
  - **0**: Does not apply.
  - **1**: Partially applies.
  - **2**: Fully applies.

  1. Does the title or thumbnail exaggerate or sensationalize the content to attract clicks?
     - Look for words or images that seem overly dramatic or extreme compared to the video content.

  2. Does the title or thumbnail use misleading or ambiguous language or images to create curiosity?
     - Identify if the title or thumbnail uses vague language or images that could mean multiple things, prompting curiosity without providing clarity.

  3. Does the title or thumbnail promise more than what the video delivers?
     - Check if the title or thumbnail suggests information, results, or content that the video fails to provide.

  4. The title or thumbnail can use emotionally charged words, phrases, or imagery to provoke a reaction as long as the video backs up the claims.
     - Ensure that any strong emotional appeal in the title or thumbnail is justified by the video content.

  Calculate the total score based on the above criteria. If the total score is 5 or higher out of 10, consider the video clickbait. Otherwise, it is not clickbait.

  Please follow these criteria closely and provide specific evidence from the video content for your conclusions.
`;

export const generateClickbaitYouTubePrompt = (
  videoTitle: string,
  transcriptText: string
): string => {
  return `
      Here is a transcript of a YouTube video along with the thumbnail of the video. Please determine 
      if the video is clickbait by comparing the thumbnail and video title against the transcript.
  
      Video Title: ${videoTitle}
      Transcript: ${transcriptText}
  
      ${clickbaitCriteriaForYouTube}
  
      1. Based on the above criteria, score each criterion on a scale of 0-2 and calculate the total score. Is the video clickbait? If the total score is 5 or higher, consider it clickbait.
      2. If the video is clickbait, explain why in one sentence using the video content as evidence but don't use the word clickbait. Provide clear examples from the content that support your explanation.
      3. Extract the answer to the question posed in the title or thumbnail (if there is one) from the video content.
      4. Provide a brief summary of the video content.
      
      Please return the information in the following JSON format:
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
