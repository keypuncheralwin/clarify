const clickbaitCriteriaForYouTube = `I will be providing you with a transcript of a YouTube video along with the thumbnail of the video. Please determine 
  if the video is clickbait by comparing the thumbnail and video title against the transcript.
  When evaluating whether the YouTube video thumbnail or title is clickbait, please consider the following criteria. Each criterion should be scored on a scale of 0-2:
  - **0**: Fully applies (indicating clickbait).
  - **1**: Partially applies.
  - **2**: Does not apply (indicating clarity).

  1. Does the title or thumbnail exaggerate or sensationalize the content to attract clicks?
     - Look for words or images that seem overly dramatic or extreme compared to the video content.

  2. Does the title or thumbnail use misleading or ambiguous language or images to create curiosity?
     - Identify if the title or thumbnail uses vague language or images that could mean multiple things, prompting curiosity without providing clarity.

  3. Does the title or thumbnail promise more than what the video delivers?
     - Check if the title or thumbnail suggests information, results, or content that the video fails to provide.

  4. The title or thumbnail can use emotionally charged words, phrases, or imagery to provoke a reaction as long as the video backs up the claims.
     - Ensure that any strong emotional appeal in the title or thumbnail is justified by the video content.

  Calculate the total clarity score based on the above criteria. If the total clarity score is 5 or lower out of 10, consider the video clickbait. Otherwise, it is not clickbait.

  Please follow these criteria closely and provide specific evidence from the video content for your conclusions.

  1. Based on the above criteria, score each criterion on a scale of 0-2 and calculate the total clarity score. Is the video clickbait? If the total clarity score is 5 or lower, consider it clickbait.
  2. If the video is clickbait, explain why in one sentence using the video content as evidence but don't use the word clickbait. Provide clear examples from the content that support your explanation.
  3. Extract the answer to the question posed in the title or thumbnail (if there is one) from the video content.
  4. Provide a brief summary of the video content.
  
  Please return the information in the following JSON format:
  {
      "title": "string",
      "isClickBait": "boolean",
      "clarityScore": number,
      "explanation": "string",
      "answer": "string",
      "summary": "string"
  }
`;

export const generateClickbaitYouTubePrompt = (
  videoTitle: string,
  transcriptText: string
): string => {
  return `
      Video Title: ${videoTitle}
      Transcript: ${transcriptText}
      `;
};

export const clarityScoreDefinitionYoutube =
  "The clarity score is a measure from 0 to 10 indicating how clear and accurate the title and thumbnail is, with higher scores indicating greater clarity and accuracy. The reason behind this video's clarity score: \n";

export const geminiYoutubeContext = [
    {
      "role": "user",
      "parts": [{ 
        text: clickbaitCriteriaForYouTube
       }
      ]},
  ]