const router = require('express').Router();
const { authenticate } = require('../middleware/auth.middleware');
const { getNotifications, markAsRead, markAllAsRead } = require('../controllers/notification.controller');

router.get('/',          authenticate, getNotifications);
router.put('/leido/all', authenticate, markAllAsRead);
router.put('/:id/leido', authenticate, markAsRead);

module.exports = router;
