import "./index.css";
import { createApp } from "vue";
import App from "./App.vue";
import { initializeGlobalEventListeners } from "./models/shortcut";

initializeGlobalEventListeners();

createApp(App).mount("#app");
