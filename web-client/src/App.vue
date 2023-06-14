<template>
  <Debugbar />

  <Navigation :tracks="navigation.tracks" :index="navigation.currentIndex" />
</template>

<script setup lang="ts">
import { h, onUnmounted } from "vue";
import { navigation, pushScreen, pushTrack } from "./models/navigation";
import { fetchApplications } from "./models/application";
import Navigation from "./components/Navigation.vue";
import Search from "./components/screen/Search.vue";
import Debugbar from "./components/Debugbar.vue";
import { registerShortcut } from "./models/shortcut";

fetchApplications().then(() => {
  const searchInstance = h(Search);

  pushTrack("Search", searchInstance);
});

onUnmounted(
  registerShortcut("ctrl+p", () => {
    const searchInstance = h(Search);

    pushScreen("Search", searchInstance);
  })
);
</script>
