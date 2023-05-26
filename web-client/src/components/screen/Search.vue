<template>
  <div>
    <input class="border p-2" v-model="query" />

    <ul>
      <li v-for="match in matches">
        <span v-html="match.highlighted_text"></span>
        {{ match.score }}
      </li>
    </ul>
  </div>
</template>

<style scope>
em {
  background-color: yellow;
}
</style>

<script setup lang="ts">
import { useSearch } from "../../models/useSearch";

const { query, matches } = useSearch();
</script>
