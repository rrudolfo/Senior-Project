// __tests__/saveUserData.test.js

const { saveUserData,
        getUserData } = require('server.js'); // Adjust path
const admin = require('firebase-admin');

//Mocking the firestore database.
const mockSet = jest.fn();
const mockDoc = jest.fn(()=>({set: mockSet}));
const mockCollection = jest.fn(()=>({doc: mockDoc}));
const mockDb = {collection: mockCollection};
const mockData = jest.fn();
const mockExists = jest.fn();
const mockGet = jest.fn(()=>({exists: mockExists, data: mockData}));

//Mocking the server timestamp.
const mockServerTimestamp = {some:'timestamp'};
admin.firestore = {
    FieldValue:{
        serverTimestamp: jest.fn(()=> mockServerTimestamp)
    }
};

describe('saveUserData', () => {
    beforeEach(() => {
        // Clear mocks before each test
        mockSet.mockClear();
        mockDoc.mockClear();
        mockExists.mockClear();
        mockCollection.mockClear();
        mockGet.mockClear();
        admin.firestore.FieldValue.serverTimestamp.mockClear();
    });

    it('should save user data successfully', async () => {
        const userId = 'testUserId';
        const name = 'Test User';
        const email = 'test@example.com';

        const result = await saveUserData(userId, name, email);

        expect(mockCollection).toHaveBeenCalledWith('users');
        expect(mockDoc).toHaveBeenCalledWith(userId);
        expect(mockSet).toHaveBeenCalledWith({
            name: name,
            email: email,
            createdAt: mockServerTimestamp,
        });
        expect(result).toBe(`Data saved for user ID: ${userId}`);
    });

    it('should handle Firestore errors', async () => {
        const userId = 'testUserId';
        const name = 'Test User';
        const email = 'test@example.com';
        const errorMessage = 'Firestore error';

        mockSet.mockRejectedValue(new Error(errorMessage));

        await expect(saveUserData(userId, name, email)).rejects.toThrow(`Error saving data: ${errorMessage}`);
    });

    it('should handle invalid data', async () => {
        const userId = 'testUserId';
        const name = 123;
        const email = true;

        await saveUserData(userId, name, email);
        expect(mockSet).toHaveBeenCalledWith({
            name: 123,
            email: true,
            createdAt: mockServerTimestamp,
        });
    });
    it('should handle invalid data', async () => {
        const userId = 'testUserId';
        const name = true;
        const email = 123;

        await saveUserData(userId, name, email);
        expect(mockSet).toHaveBeenCalledWith({
            name: 123,
            email: true,
            createdAt: mockServerTimestamp,
        });
        //Add more tests to verify how firestore handles the invalid data.
      
    });
    it('should retrieve user data successfully', async () => {
      const userId = 'testUserID';
      const expected = {name: 'Test User', email: 'test@example.com'};
      const result = await getUserData(userId);
      expect(result).toEqual(expected);
    });
});