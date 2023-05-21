import { Component, reactive, ref } from "vue";

export interface Screen {
  title: string;
  component: Component;
}

export interface Track {
  currentStackIndex: number;
  screens: Screen[];
}

export interface Navigation {
  tracks: Track[];
  currentIndex: number;
}

export const navigation = reactive<Navigation>({ tracks: [], currentIndex: 0 });

export const currentTrackIndex = ref<number>(0);

export function pushTrack(title: string, component: Component) {
  const screen: Screen = { title, component };

  navigation.tracks.push({
    currentStackIndex: 0,
    screens: [screen],
  });
}

export function replaceCurrentScreen(title: string, component: Component) {
  const track = navigation.tracks[currentTrackIndex.value];

  track.screens[track.currentStackIndex] = { title, component };
}
