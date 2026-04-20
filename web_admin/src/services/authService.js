import { signInWithEmailAndPassword } from "firebase/auth";
import { auth } from "../firebase/config";

export const login = async (email, password) => {
    return await signInWithEmailAndPassword(auth, email, password);
};