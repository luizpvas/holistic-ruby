import { Component, reactive, ref } from "vue";

export interface Screen {
  title: string;
  component: Component;
}

export interface Track {
  currentIndex: number;
  screens: Screen[];
}

export interface Navigation {
  tracks: Track[];
  currentIndex: number;
}

export const navigation = reactive<Navigation>({ tracks: [], currentIndex: 0 });

export function updateCurrenTitle(title: string) {
  const track = navigation.tracks[navigation.currentIndex];
  const screen = track.screens[track.currentIndex];

  screen.title = title;
}

export function pushTrack(title: string, component: Component) {
  const screen: Screen = { title, component };

  navigation.tracks.push({
    currentIndex: 0,
    screens: [screen],
  });
}

export function pushScreen(title: string, component: Component) {
  const track = navigation.tracks[navigation.currentIndex];

  track.screens.push({ title, component });
  track.currentIndex = track.currentIndex + 1;
}
