// import { Request, Response, NextFunction } from 'express';
// import admin from 'firebase-admin';

// export const verifyAuthToken = async (
//   req: Request,
//   res: Response,
//   next: NextFunction
// ): Promise<void> => {
//   const token = req.headers.authorization?.split('Bearer ')[1];

//   if (!token) {
//     res.status(403).send('Unauthorized');
//     return;
//   }

//   try {
//     const decodedToken = await admin.auth().verifyIdToken(token);
//     req.user = decodedToken;
//     next();
//   } catch (error) {
//     res.status(403).send('Unauthorized');
//   }
// };
