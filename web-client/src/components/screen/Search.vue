<template>
  <div>
    <input class="border p-2" />

    <ul>
      <li v-for="namespace in rootNamespaces">
        {{ namespace }}
      </li>
    </ul>
  </div>
</template>

<script setup lang="ts">
import { useSearch } from "../../models/useSearch";

const { rootNamespaces } = useSearch();
</script>
