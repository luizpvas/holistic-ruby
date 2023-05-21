<script setup lang="ts">
import { createApp } from 'vue';
import { navigation, pushTrack } from './models/navigation';
import { fetchApplications } from './models/application';
import Search from './components/screen/Search.vue';
import Debugbar from './components/Debugbar.vue';

fetchApplications().then(() => {
  pushTrack('Search', createApp(Search));
});
</script>

<template>
  <Debugbar />

  <div v-for="track in navigation.tracks">
    <div v-for="screen in track.screens">
      <div>{{ screen.title }}</div>
    </div>
  </div>
</template>
