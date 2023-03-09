const functions = require("firebase-functions");
const admin =require("firebase-admin");
admin.initializeApp();

exports.sendToFollowers = functions.firestore.
    document("products/{product}").
    onCreate((snapshot, context) => {
      const myTopic = `${snapshot.data().supplierIdsnapshot.data()
          .supplierId}store`;
      const message ={
        data: {
          type: "followers",
          supplierId: snapshot.data().supplierId,
        },
        android: {
          notification: {
            title: "New Item that you might be interested in",
            body: snapshot.data().productName,
          },
        },
        topic: myTopic,
      };
      // admin => send notification
      admin.messaging().send(message).
          then((response)=> {
            console.log("message sent succesfully", response);
          }).catch((error) => {
            console.log("error sending message", error);
          });
    });
