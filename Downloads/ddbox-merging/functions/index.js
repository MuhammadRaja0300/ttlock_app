//const {onRequest} = require("firebase-functions/v2/https");
//const logger = require("firebase-functions/logger");


const functions = require('firebase-functions');
const admin = require('firebase-admin');
const express = require('express');
const sgMail = require('@sendgrid/mail');
const cors = require('cors');

admin.initializeApp();

exports.sendNotificationOnPushButton = functions.database.ref('/users/users_details/{uid}')
   .onUpdate(async (change, context) => {
       const newValue = change.after.val();
       const previousValue = change.before.val();

       if (newValue.device_commands.push_button === true && previousValue.device_commands.push_button === false) {
           const userUid = context.params.uid;
           console.log('Push_Button is false from NOde.JS OF UID:-' + userUid);
           try {
           const fcmToken = newValue.fcm_token;
            if (fcmToken) {
              const title = 'Box is Knocked'; // Replace with your dynamic title logic
              const body = '';   // Replace with your dynamic body logic

              const notification = {
                title,
                body,
              };

              const message = {
                notification,
                token: fcmToken,
              };

              try {
                const response = await admin.messaging().send(message);
                console.log(`Successfully sent notification to user ${uid}`, response);
              } catch (error) {
                console.log(`Error sending notification to user ${uid}`, error.message);
              }
            } else {
              console.log(`FCM token not found for user ${uid}`);
            }
                 } catch (error) {
                   console.log('Error fetching data from the database', error.message);
                 }

                 let childRelation = newValue.child_relation;
       const keys = Object.keys(childRelation);
        for (const key in keys) {
          const value = keys[key];
          console.log(`Key: ${key}, Value:`, value);
          let fcm_token = childRelation[value].fcm_token;
            try {
            const fcmToken = fcm_token;
             if (fcmToken) {
              const title = 'Box is Knocked'; // Replace with your dynamic title logic
              const body = '';   // Replace with your dynamic body logic
 
               const notification = {
                 title,
                 body,
               };
 
               const message = {
                 notification,
                 token: fcmToken,
               };
 
               try {
                 const response = await admin.messaging().send(message);
                 console.log(`Successfully sent notification to user ${uid}`, response);
               } catch (error) {
                 console.log(`Error sending notification to user ${uid}`, error.message);
               }
             } else {
               console.log(`FCM token not found for user ${uid}`);
             }
                  } catch (error) {
                    console.log('Error fetching data from the database', error.message);
                  }
    
          }
       }
       return null;
   });


   exports.sendNotificationLockStatusChanged = functions.database.ref('/users/users_details/{uid}')
      .onUpdate(async (change, context) => {
      console.log('1');
          const newValue = change.after.val();
          const previousValue = change.before.val();

          if (newValue.status.lock_status === true && previousValue.status.lock_status === false) {
              const userUid = context.params.uid;
              console.log('Lock is true from NOde.JS OF UID:-' + userUid);
              try {
              const fcmToken = newValue.fcm_token;
              if (fcmToken) {
                  console.log('4');
                    const title = 'The Box Is Locked'; // Replace with your dynamic title logic
                    const body = '';   // Replace with your dynamic body logic

                    const notification = {
                      title,
                      body,
                    };

                    const message = {
                      notification,
                      token: fcmToken,
                    };

                    try {
                      const response = await admin.messaging().send(message);
                      console.log(`Successfully sent notification to user ${uid}`, response);
                    } catch (error) {
                      console.log(`Error sending notification to user ${uid}`, error.message);
                    }
                  } else {
                    console.log(`FCM token not found for user ${uid}`);
                  }
                    } catch (error) {
                      console.log('Error fetching data from the database', error.message);
                    }

                    let childRelation = newValue.child_relation;
       const keys = Object.keys(childRelation);
        for (const key in keys) {
          const value = keys[key];
          console.log(`Key: ${key}, Value:`, value);
          let fcm_token = childRelation[value].fcm_token;
            try {
            const fcmToken = fcm_token;
             if (fcmToken) {
                const title = 'The Box Is Locked'; // Replace with your dynamic title logic
                    const body = '';   // Replace with your dynamic body logic
 
               const notification = {
                 title,
                 body,
               };
 
               const message = {
                 notification,
                 token: fcmToken,
               };
 
               try {
                 const response = await admin.messaging().send(message);
                 console.log(`Successfully sent notification to user ${uid}`, response);
               } catch (error) {
                 console.log(`Error sending notification to user ${uid}`, error.message);
               }
             } else {
               console.log(`FCM token not found for user ${uid}`);
             }
                  } catch (error) {
                    console.log('Error fetching data from the database', error.message);
                  }
        
          }
          }
          if (newValue.status.lock_status === false && previousValue.status.lock_status === true) {
                        const userUid = context.params.uid;
                        console.log('UnLock is true from NOde.JS OF UID:-' + userUid);
                        try {
                               const fcmToken = newValue.fcm_token;
                                 if (fcmToken) {
                                 console.log('fcm token =' + fcmToken);
                                   const title = 'The Box Is Unlocked'; // Replace with your dynamic title logic
                                   const body = '';   // Replace with your dynamic body logic

                                   const notification = {
                                     title,
                                     body,
                                   };

                                   const message = {
                                     notification,
                                     token: fcmToken,
                                   };

                                   try {
                                     const response = await admin.messaging().send(message);
                                     console.log(`Successfully sent notification to user ${uid}`, response);
                                   } catch (error) {
                                     console.log(`Error sending notification to user ${uid}`, error.message);
                                   }
                                 } else {
                                   console.log(`FCM token not found for user ${uid}`);
                                 }
                              } catch (error) {
                                console.log('Error fetching data from the database', error.message);
                              }
                              let childRelation = newValue.child_relation;
       const keys = Object.keys(childRelation);
        for (const key in keys) {
          const value = keys[key];
          console.log(`Key: ${key}, Value:`, value);
          let fcm_token = childRelation[value].fcm_token;
            try {
            const fcmToken = fcm_token;
             if (fcmToken) {
              const title = 'The Box Is Unlocked'; // Replace with your dynamic title logic
              const body = '';   // Replace with your dynamic body logic
 
               const notification = {
                 title,
                 body,
               };
 
               const message = {
                 notification,
                 token: fcmToken,
               };
 
               try {
                 const response = await admin.messaging().send(message);
                 console.log(`Successfully sent notification to user ${uid}`, response);
               } catch (error) {
                 console.log(`Error sending notification to user ${uid}`, error.message);
               }
             } else {
               console.log(`FCM token not found for user ${uid}`);
             }
                  } catch (error) {
                    console.log('Error fetching data from the database', error.message);
                  }
    
          }
                    }
          return null;
      });

//exports.sendEmailOnTempIncrease = functions.database.ref('/users/users_details/{uid}').onUpdate(async (change, context) => {
//       const newValue = change.after.val();
//       const previousValue = change.before.val();
//       console.log('NEW VALUE ======' + newValue.status.temperature);
//       if (newValue.status.temperature > 15 && previousValue.status.temperature < 10) {
//
//           const userUid = context.params.uid;
//           console.log('temperature increase from NOde.JS OF UID:-' + userUid);
//
//           console.log('email sending 1');
//           sgMail.setApiKey(
//                 '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',
//               );
//           console.log('email sending 2');
//           const msg = {
//                   from:'muneebumughal84@icloud.com',
//                   //templateId: ‘TEMPLETE_ID’,
//                   to: 'muhammadraja0300@gmail.com',
//                   subject: 'Welcome to [Your Box Name] - Confirm Your Email to Secure Your Deliveries!',
//                   text: 'and easy to do anywhere, even with Node.js',
//                     html: '<strong>and easy to do anywhere, even with Node.js</strong>',
//
//                 };
//
//           sgMail.send(msg).then(async () => {
//                     console.log('Email sent');
//                   })
//                   .catch(async (error) => {
//                     console.error(error);
//                   });
//           try {
//           const fcmToken = newValue.fcm_token;
//            if (fcmToken) {
//              const title = 'Email Send '; // Replace with your dynamic title logic
//              const body = '';   // Replace with your dynamic body logic
//
//              const notification = {
//                title,
//                body,
//              };
//
//              const message = {
//                notification,
//                token: fcmToken,
//              };
//
//              try {
//                const response = await admin.messaging().send(message);
//                console.log(`Successfully sent notification to user ${uid}`, response);
//              } catch (error) {
//                console.log(`Error sending notification to user ${uid}`, error.message);
//              }
//            } else {
//              console.log(`FCM token not found for user ${uid}`);
//            }
//            console.log('email sending 1');
//                        sgMail.setApiKey(
//                              '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',
//                            );
//                        console.log('email sending 2');
//                        const msg = {
//                                from:'muhammadraja0300@gmail.com',
//
//
//                                //templateId: ‘TEMPLETE_ID’,
//                                to: 'usmangulzar.a@gmail.com',
//                                subject: 'Welcome to [Your Box Name] - Confirm Your Email to Secure Your Deliveries!',
//                                text: 'and easy to do anywhere, even with Node.js',
//                                  html: '<strong>and easy to do anywhere, even with Node.js</strong>',
//
//                              };
//
//                        sgMail.send(msg).then(async () => {
//                                  console.log('Email sent');
//                                })
//                                .catch(async (error) => {
//                                  console.error(error);
//                                });
//
//                 } catch (error) {
//                   console.log('Error fetching data from the database', error.message);
//                 }
//       }
//       return null;
//   });


exports.sendNotificationTempIncrease = functions.database.ref('/users/users_details/{uid}').onUpdate(async (change, context) => {
       const newValue = change.after.val();
       const previousValue = change.before.val();
       if (newValue.status.temperature > 44 && previousValue.status.temperature < 44) {
           try {
           const fcmToken = newValue.fcm_token;
            if (fcmToken) {
              const title = 'Temperature is increased '; // Replace with your dynamic title logic
              const body = '';   // Replace with your dynamic body logic

              const notification = {
                title,
                body,
              };

              const message = {
                notification,
                token: fcmToken,
              };

              try {
                const response = await admin.messaging().send(message);
                console.log(`Successfully sent notification to user ${uid}`, response);
              } catch (error) {
                console.log(`Error sending notification to user ${uid}`, error.message);
              }
            } else {
              console.log(`FCM token not found for user ${uid}`);
            }


                 } catch (error) {
                   console.log('Error fetching data from the database', error.message);
                 }
       }
       let childRelation = newValue.child_relation;
       const keys = Object.keys(childRelation);
        for (const key in keys) {
          const value = keys[key];
          console.log(`Key: ${key}, Value:`, value);
          let fcm_token = childRelation[value].fcm_token;

          if (newValue.status.temperature > 44 && previousValue.status.temperature < 44) {
            try {
            const fcmToken = fcm_token;
             if (fcmToken) {
               const title = 'Temperature is increased '; // Replace with your dynamic title logic
               const body = '';   // Replace with your dynamic body logic
 
               const notification = {
                 title,
                 body,
               };
 
               const message = {
                 notification,
                 token: fcmToken,
               };
 
               try {
                 const response = await admin.messaging().send(message);
                 console.log(`Successfully sent notification to user ${uid}`, response);
               } catch (error) {
                 console.log(`Error sending notification to user ${uid}`, error.message);
               }
             } else {
               console.log(`FCM token not found for user ${uid}`);
             }
 
 
                  } catch (error) {
                    console.log('Error fetching data from the database', error.message);
                  }
        }
          }
       return null;
   });

//const SENDGRID_API_KEY = 'YOUR_SENDGRID_API_KEY';
//const SENDER_EMAIL = 'your-email@example.com';
//sgMail.setApiKey(SENDGRID_API_KEY);



exports.sendWelcomeEmail = functions.auth.user().onCreate((user) => {
console.log('user data' + user.email);
  const { email, displayName } = user;

  const uemail = user.email;
console.log('email sending 1');
           sgMail.setApiKey(
                 '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',
               );
           console.log('email sending 2');
           const msg = {
                   from:'mydrop@mydrop.ae',
                   to: user.email,
                   subject: 'Welcome RAJA [Your Box Name] - Confirm Your Email to Secure Your Deliveries!',
                   text: 'and easy to do anywhere, even with Node.js',
                     html: '<strong>and easy to do anywhere, even with Node.js</strong>',
                    templateId: 'd-21f631cc75d94b5f83b0aec865e44adc',
                 };

           sgMail.send(msg).then(async () => {
                     console.log('Email sent');
                   })
                   .catch(async (error) => {
                     console.error(error);
                   });
                    return null;
});




//const app = express();
//app.use(cors({ origin: true }));
//
//sgMail.setApiKey('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');
//
//app.post('/sendWelcomeEmail', async (req, res) => {
//  try {
//    // Extract user data from the request, assuming it's sent in the request body
//    const { email, displayName } = req.body;
//
//    const msg = {
//      from: {
//        name: 'XYZ',
//        email: 'muhammadraja0300@gmail.com',
//      },
//      to: email,
//      subject: 'Welcome to [Your Box Name] - Confirm Your Email to Secure Your Deliveries!',
//      text: 'and easy to do anywhere, even with Node.js',
//      html: '<strong>and easy to do anywhere, even with Node.js</strong>',
//    };
//
//    await sgMail.send(msg);
//
//    console.log('Email sent');
//    return res.status(200).json({ success: true, message: 'Email sent successfully' });
//  } catch (error) {
//    console.error(error);
//    return res.status(500).json({ success: false, message: 'Failed to send email' });
//  }
//});
//
//exports.sendWelcomeEmailOnAppOpen = functions.https.onRequest(app);





