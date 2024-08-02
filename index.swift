// Import Firebase modules
import firebase from 'firebase/app';
import 'firebase/auth';
import 'firebase/firestore';
import 'firebase/database';

class UserDataDeletion {
  constructor() {
    this.auth = firebase.auth();
    this.firestore = firebase.firestore();
    this.realtimeDb = firebase.database();
  }

  async deleteUserData(userId) {
    try {
      // Ensure the user is authenticated
      const currentUser = this.auth.currentUser;
      if (!currentUser || currentUser.uid !== userId) {
        throw new Error('User not authenticated or mismatch in user ID');
      }

      // Delete Firestore data
      await this.deleteFirestoreData(userId);

      // Delete Realtime Database data
      await this.deleteRealtimeDatabaseData(userId);

      // Delete user authentication account
      await currentUser.delete();

      console.log('User data and account successfully deleted');
      return true;
    } catch (error) {
      console.error('Error deleting user data:', error);
      throw error;
    }
  }

  async deleteFirestoreData(userId) {
    // Delete user's personal data collection
    await this.deleteCollection(`users/${userId}/personalData`);

    // Delete user's document in the users collection
    await this.firestore.collection('users').doc(userId).delete();

    // Add more collection deletions as needed
  }

  async deleteCollection(collectionPath) {
    const collectionRef = this.firestore.collection(collectionPath);
    const batch = this.firestore.batch();
    
    const snapshot = await collectionRef.get();
    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();
  }

  async deleteRealtimeDatabaseData(userId) {
    // Delete user's node in the Realtime Database
    await this.realtimeDb.ref(`users/${userId}`).remove();

    // Add more node deletions as needed
  }
}

// Usage example
const deleteUserData = async (userId) => {
  const userDataDeletion = new UserDataDeletion();
  try {
    await userDataDeletion.deleteUserData(userId);
    console.log('User data deleted successfully');
  } catch (error) {
    console.error('Failed to delete user data:', error);
  }
};

// Call the function with a user ID
// deleteUserData('exampleUserId');
