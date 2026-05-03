const { collection, addDoc, getDocs, deleteDoc, updateDoc, query, where, getDoc, doc, serverTimestamp } = require("firebase/firestore");

const { db } = require('../config/firebase');

const productCollection = collection(db, "products");

// Obtener todos los productos
async function getAllProducts() {
    const snapshot = await getDocs(productCollection);

    return snapshot.docs.map(d => {
        const product = d.data();

        return {
            id: d.id,
            ...product,
            createdAt: product.createdAt?.toDate(),
            updatedAt: product.updatedAt?.toDate()
        };
    });
}

// Obtener producto por ID
async function getById(id) {
    const productRef = doc(db, "products", id);
    const productSnap = await getDoc(productRef);

    if (!productSnap.exists()) return null;

    const product = productSnap.data();

    return {
        id: productSnap.id,
        ...product,
        createdAt: product.createdAt?.toDate(),
        updatedAt: product.updatedAt?.toDate()
    };
}

// Buscar producto por nombre
async function findByName(name) {
    const nameClean = name.trim().toLowerCase();

    const q = query(productCollection, where("nameSearch", "==", nameClean));
    const snapshot = await getDocs(q);

    if (snapshot.empty) return null;

    const docData = snapshot.docs[0];
    const data = docData.data();

    return {
        id: docData.id,
        ...data,
        createdAt: data.createdAt?.toDate(),
        updatedAt: data.updatedAt?.toDate()
    };
}

// Crear producto
async function createProduct({ name, description, price, category, image, state, stock, minStock }) {
    try {
        if (!name?.trim() || price == null || price < 0) {
            throw new Error("Invalid data");
        }

        const nameClean = name.trim().toLowerCase();

        const existing = await findByName(nameClean);
        if (existing) return null;

        const data = {
            name: name.trim(),
            nameSearch: nameClean, 
            description: description || "",
            price,
            category,
            image,
            state: state ?? true,
            stock: stock ?? 0,
            minStock: minStock ?? 0,
            createdAt: serverTimestamp()
        };

        Object.keys(data).forEach(key => {
            if (data[key] === undefined) {
                delete data[key];
            }
        });

        const docRef = await addDoc(productCollection, data);

        return {
            id: docRef.id,
            ...data
        };

    } catch (err) {
        console.error("Error creating product:", err);
        throw err;
    }
}

// Actualizar producto
async function updateProduct(id, data) {
    const existing = await getById(id);
    if (!existing) return null;

    if (data.name) {
        const nameClean = data.name.trim().toLowerCase();

        const existingProduct = await findByName(nameClean);
        if (existingProduct && existingProduct.id !== id) return null;

        data.name = data.name.trim();  
        data.nameSearch = nameClean;    
    }

    if (data.price != null && data.price < 0) {
        throw new Error("Invalid price");
    }

    delete data.createdAt;
    delete data.updatedAt;
    delete data.id;

    Object.keys(data).forEach(key => {
        if (data[key] === undefined) {
            delete data[key];
        }
    });

    await updateDoc(doc(db, "products", id), {
        ...data,
        updatedAt: serverTimestamp()
    });

    return getById(id);
}

// Eliminar producto
async function deleteProduct(id) {
    const productRef = doc(db, "products", id);
    const productSnap = await getDoc(productRef);

    if (!productSnap.exists()) return null;

    await deleteDoc(productRef);

    return { id };
}

module.exports = { getAllProducts, getById, findByName, createProduct, updateProduct, deleteProduct };