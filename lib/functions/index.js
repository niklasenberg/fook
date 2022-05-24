const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp(functions.config().firebase);
let msgData;

exports.chatNotifier = functions.firestore
    .document("chats/{chatId}/messages/{messageId}").onCreate((snapshot) => {
        msgData = snapshot.data();
        const payload = {
            "notification": {
                "title": "From: " + msgData["senderName"],
                "body": msgData["message"],
                "sound": "default",
            },
            "data": {
                "sendername": "functions",
                "message": "hejsan",
            },
        };

        let token;

        admin.firestore().collection("tokens")
            .doc(msgData["to"].toString())
            .get().then((snapshot) => {
            token = snapshot.data()["token"];
            return admin.messaging().sendToDevice(token, payload)
                .then(() => {
                    console.log("pushed them all");
                    console.log(token);
                }).catch((err) => {
                    console.log(err);
                });
        });
    });

exports.newCourse = functions.firestore
    .document("users/{userID}").onUpdate((change, context) => {
        const userID = change.after.id;
        console.log("Before: " + change.before.data()["courses"].toString());
        console.log("After: " + change.after.data()["courses"].toString());

        if (change.before.data()["courses"].toString() !==
            change.after.data()["courses"].toString()) {
            const payload = {
                "notification": {
                    "title": "New courses!",
                    "body": "You were just registered on new courses, " +
                        "maybe you should buy some literature?",
                    "sound": "default",
                },
                "data": {
                    "sendername": "functions",
                    "message": "hejsan",
                },

            };

            let token;

            admin.firestore().collection("tokens")
                .doc(userID.toString())
                .get().then((snapshot) => {
                token = snapshot.data()["token"];
                return admin.messaging().sendToDevice(token, payload)
                    .then(() => {
                        console.log("pushed them all");
                        console.log(token);
                    }).catch((err) => {
                        console.log(err);
                    });
            });
        } else {
            return false;
        }
    });

exports.notifyOldSales = functions.pubsub.schedule("0 0 1 * *").onRun(() => {
    const date = new Date();
    date.setMonth(date.getMonth() - 1);
    const aMonthAgo = admin.firestore.Timestamp.fromDate(date);
    admin.firestore().collection("sales")
        .where("publishedDate", "<", aMonthAgo).get()
        .then((snapshot) => {
            snapshot.forEach(
                (doc) => {
                    console.log(doc.data()["saleID"].toString() +
                        "is more than a month old, sending notification");
                    admin.firestore().collection("tokens")
                        .doc(doc.data()["userID"].toString())
                        .get().then((snapshot) => {
                        const token = snapshot.data()["token"].toString();

                        const payload = {
                            "notification": {
                                "title": "Sale needs updating!",
                                "body": "Your sale for " + doc.data()["isbn"] +
                                    " needs to be updated, or it will be removed.",
                                "sound": "default",
                            },
                            "data": {
                                "sendername": "functions",
                                "message": "hejsan",
                            },
                        };

                        return admin.messaging().sendToDevice(token, payload)
                            .then(() => {
                                console.log("pushed them all");
                                console.log(token);
                                return true;
                            }).catch((err) => {
                                console.log(err);
                                return false;
                            });
                    });
                });
        });
});

exports.deleteOldSales = functions.pubsub.schedule("0 0 7 */2 *").onRun(() => {
    const date = new Date();
    date.setMonth(date.getMonth() - 1);
    const aMonthAgo = admin.firestore.Timestamp.fromDate(date);
    admin.firestore().collection("sales")
        .where("publishedDate", "<", aMonthAgo).get()
        .then((snapshot) => {
            snapshot.forEach(
                (doc) => {
                    admin.firestore().collection("sales").doc(doc.id).delete()
                        .then(() =>
                            admin.firestore().collection("tokens")
                                .doc(doc.data()["userID"].toString())
                                .get().then((snapshot) => {
                                const token = snapshot.data()["token"].toString();

                                const payload = {
                                    "notification": {
                                        "title": "Sale deleted!",
                                        "body": "Your sale for " + doc.data()["isbn"] +
                                            " was removed due to not being updated.",
                                        "sound": "default",
                                    },
                                    "data": {
                                        "sendername": "functions",
                                        "message": "hejsan",
                                    },
                                };

                                return admin.messaging().sendToDevice(token, payload)
                                    .then(() => {
                                        console.log("pushed them all");
                                        console.log(token);
                                        return true;
                                    }).catch((err) => {
                                        console.log(err);
                                        return false;
                                    });
                            })
                        );
                });
        });
});
