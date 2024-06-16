const clickbaitCriteriaForYouTube = `
  When evaluating whether the YouTube video thumbnail or title is clickbait, please consider the following criteria:
  1. Does the title or thumbnail exaggerate or sensationalize the content to attract clicks?
  2. Does the title or thumbnail use misleading or ambiguous language or images to create curiosity?
  3. Does the title or thumbnail promise more than what the video delivers?
  4. The title or thumbnail can use emotionally charged words, phrases, or imagery to provoke a reaction as long as the video backs up the claims, 
  in which case the video is not considered clickbait.
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
  
      1. Is the video clickbait? If so, explain why briefly.
      2. Provide a brief summary of the video content. If the thumbnail poses a question, what is the answer?
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
