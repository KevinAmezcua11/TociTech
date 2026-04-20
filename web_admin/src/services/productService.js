import { db } from "../firebase/config";
import { collection, addDoc, getDocs, deleteDoc, updateDoc, doc } from "firebase/firestore";

const productRef = collection(db, "products");

// Obtener productos
export const getProducts = async () => {
    const snapshot = await getDocs(productRef);
    return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
    }));
};

// Crear producto
export const addProduct = async (product) => {
    return await addDoc(productRef, product);
};

// Eliminar producto
export const deleteProduct = async (id) => {
    return await deleteDoc(doc(db, "products", id));
};

// Actualizar productos
export const updateProduct = async (id, updatedData) => {
    const productDoc = doc(db, "products", id);
    return await updateDoc(productDoc, updatedData);
};