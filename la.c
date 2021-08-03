#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>
#include <math.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MINIAUDIO_IMPLEMENTATION
#include "libs/miniaudio.h"

// lua
#define LA_TMP_FILENAME "/tmp/la_tmp.lua"
lua_State *L;
bool reload = false;
bool error = false;
// ~lua

// audio
ma_device device;
// ~audio

void data_callback(ma_device *dev, void *out, const void *in,
                   ma_uint32 bufsize) {
  float *outbuf = (float *)out;

  lua_pushinteger(L, (double)bufsize);
  lua_setglobal(L, "bufsz");

  lua_getglobal(L, "run");
  if (lua_pcall(L, 0, 0, 0)) {
    if (!error) {
      printf("\n[lua error] %s\n", lua_tostring(L, lua_gettop(L)));
      lua_pop(L, lua_gettop(L));
      error = true;
    }
  } else {
    lua_getglobal(L, "buf");
    for (int i = 1; i <= bufsize; ++i) {
      lua_rawgeti(L, -1, i * 2 - 1);
      lua_rawgeti(L, -2, i * 2);
      outbuf[(i - 1) * 2 + 0] = lua_tonumber(L, -2);
      outbuf[(i - 1) * 2 + 1] = lua_tonumber(L, -1);
      lua_pop(L, 2);
    }
    lua_pop(L, 1);
  }

  if (reload) {
    luaL_dofile(L, LA_TMP_FILENAME);
    reload = false;
    error = false;
  }
}

int init_lua() {
  printf("[lua] init lua...\n");
  L = luaL_newstate();
  luaL_openlibs(L);

  luaL_dofile(L, "la.lua");

  lua_pushnumber(L, (double)device.sampleRate);
  lua_setglobal(L, "rate");

  lua_pushinteger(L, (double)device.playback.internalPeriodSizeInFrames);
  lua_setglobal(L, "bufsz");

  lua_createtable(L, 0, 0);
  for (int i = 1; i <= device.playback.internalPeriodSizeInFrames * 2; i++) {
    lua_pushinteger(L, i % 2 == 0 ? -1 : 1);
    lua_rawseti(L, -2, i);
  }
  lua_setglobal(L, "buf");

  printf("[lua] init lua: successful\n");
  return 0;
}

int init_audio() {
  printf("[audio] init audio...\n");
  ma_device_config config = ma_device_config_init(ma_device_type_playback);
  config.playback.format = ma_format_f32;
  config.playback.channels = 2;
  config.sampleRate = 0; // use default
  config.dataCallback = data_callback;

  if (ma_device_init(NULL, &config, &device) != MA_SUCCESS) {
    printf("[audio] init audio: failed!\n");
    return -1;
  }

  printf("[audio] init audio: successful!\n");
  return 0;
}

void print_command() {
  FILE *fp;
  if ((fp = fopen("/tmp/la_tmp.lua", "r"))) {
    int c;
    while (1) {
      c = fgetc(fp);
      if (feof(fp))
        break;
      if (c == '\n')
        printf(" ");
      else if (c != '\t')
        printf("%c", c);
    }
    printf("\n");
    fclose(fp);
  }
}

int main(int argc, char **argv) {

  if (init_audio() || init_lua())
    return 1;

  ma_device_start(&device);

  printf("repl started, press enter to reload...\n");
  char input_buffer[512];
  while (1) {
    printf("#");
    if (!fgets(input_buffer, 512, stdin))
      break;
    else {
      reload = true;
      print_command();
    }
  }

  ma_device_uninit(&device);
  lua_close(L);

  return 0;
}
