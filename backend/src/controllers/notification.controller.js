const db = require('../config/firebase');

async function getNotifications(req, res) {
    try {
        const isAdmin = req.user.role === 'admin';
        let query = db.collection('notifications').orderBy('createdAt', 'desc').limit(40);

        if (!isAdmin) {
            query = query.where('customerId', '==', req.user.id);
        }

        const snap = await query.get();
        const list = snap.docs.map(d => ({
            id: d.id,
            ...d.data(),
            createdAt: d.data().createdAt?.toDate() ?? null
        }));

        res.json(list);
    } catch (err) {
        console.error('[Notifications] getNotifications error:', err);
        res.status(500).json({ message: 'Error al obtener notificaciones' });
    }
}

async function markAsRead(req, res) {
    try {
        const ref = db.collection('notifications').doc(req.params.id);
        const snap = await ref.get();
        if (!snap.exists) return res.status(404).json({ message: 'Notificación no encontrada' });

        const data = snap.data();
        const isAdmin = req.user.role === 'admin';
        if (!isAdmin && data.customerId !== req.user.id) {
            return res.status(403).json({ message: 'Sin permiso' });
        }

        await ref.update({ leido: true });
        res.json({ ok: true });
    } catch (err) {
        console.error('[Notifications] markAsRead error:', err);
        res.status(500).json({ message: 'Error al actualizar notificación' });
    }
}

async function markAllAsRead(req, res) {
    try {
        const isAdmin = req.user.role === 'admin';
        let query = db.collection('notifications').where('leido', '==', false);

        if (!isAdmin) {
            query = query.where('customerId', '==', req.user.id);
        }

        const snap = await query.get();

        if (!snap.empty) {
            const batch = db.batch();
            snap.docs.forEach(d => batch.update(d.ref, { leido: true }));
            await batch.commit();
        }

        res.json({ ok: true, updated: snap.size });
    } catch (err) {
        console.error('[Notifications] markAllAsRead error:', err);
        res.status(500).json({ message: 'Error al marcar como leídas' });
    }
}

module.exports = { getNotifications, markAsRead, markAllAsRead };
