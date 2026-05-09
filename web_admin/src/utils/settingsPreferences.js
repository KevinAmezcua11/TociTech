export const SETTINGS_STORAGE_KEY = "adminSettings";

export const defaultSettings = {
    theme: "dark",
    notifications: true,
};

function normalizeSettings(settings) {
    const theme = settings?.theme === "light" ? "light" : "dark";
    const notifications =
        typeof settings?.notifications === "boolean"
            ? settings.notifications
            : defaultSettings.notifications;

    return {
        theme,
        notifications,
    };
}

export function loadSettings() {
    try {
        const storedSettings = localStorage.getItem(SETTINGS_STORAGE_KEY);

        if (!storedSettings) {
            return defaultSettings;
        }

        return normalizeSettings(JSON.parse(storedSettings));
    } catch {
        return defaultSettings;
    }
}

export function saveSettings(settings) {
    const normalizedSettings = normalizeSettings(settings);
    localStorage.setItem(SETTINGS_STORAGE_KEY, JSON.stringify(normalizedSettings));

    return normalizedSettings;
}

export function applyTheme(theme) {
    if (typeof document === "undefined") return;

    const normalizedTheme = theme === "light" ? "light" : "dark";
    const isLight = normalizedTheme === "light";
    const styleId = "admin-theme-overrides";
    let style = document.getElementById(styleId);

    if (!style) {
        style = document.createElement("style");
        style.id = styleId;
        document.head.appendChild(style);
    }

    document.documentElement.dataset.adminTheme = normalizedTheme;
    document.documentElement.style.colorScheme = isLight ? "light" : "dark";
    document.body.style.backgroundColor = isLight ? "#F7F8FC" : "#0F0F14";

    style.textContent = isLight
        ? `
            .bg-background { background-color: #F7F8FC !important; }
            .bg-surface { background-color: #FFFFFF !important; }
            .bg-surface\\/50 { background-color: #FFFFFF !important; }
            .bg-surfaceDark { background-color: #EEF2F8 !important; }
            .bg-surfaceDark\\/80 { background-color: rgba(238, 242, 248, 0.86) !important; }
            .text-white { color: #171923 !important; }
            .text-secondary { color: rgba(23, 25, 35, 0.72) !important; }
            .text-muted { color: rgba(23, 25, 35, 0.50) !important; }
            .border-white\\/15, .border-white\\/10, .border-white\\/8, .border-white\\/6, .border-white\\/5 { border-color: #E4E8F2 !important; }
            .bg-white\\/10, .bg-white\\/8, .bg-white\\/6, .bg-white\\/5, .bg-white\\/4, .bg-white\\/\\[0\\.02\\] { background-color: #F0F3FA !important; }
            .hover\\:bg-surface:hover,
            .hover\\:bg-white\\/10:hover,
            .hover\\:bg-white\\/8:hover,
            .hover\\:bg-white\\/6:hover,
            .hover\\:bg-white\\/5:hover,
            .hover\\:bg-white\\/4:hover {
                background-color: #E9EEFA !important;
            }
            .hover\\:text-white:hover { color: #111827 !important; }
            section.bg-surface,
            form.bg-surface,
            div.bg-surface,
            a.bg-surface\\/50 {
                box-shadow: 0 10px 24px rgba(30, 41, 59, 0.06);
            }
        `
        : "";
}

export function applySavedAdminSettings() {
    const settings = loadSettings();
    applyTheme(settings.theme);

    return settings;
}