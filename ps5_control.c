#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <unistd.h>

#define ICC_IOC_MAGIC 'I'
#define ICC_FAN_CHANGE_SERVO_PATTERN _IOW(ICC_IOC_MAGIC, 1, uint8_t)

#define MP1_IOC_MAGIC 'M'
#define MP1_BOOST_ENTER _IO(MP1_IOC_MAGIC, 1)
#define MP1_BOOST_EXIT _IO(MP1_IOC_MAGIC, 2)

void print_usage(char *prog) {
  fprintf(stderr, "Usage:\n");
  fprintf(stderr, "  %s --fan <on|off>\n", prog);
  fprintf(stderr, "  %s --boost <on|off>\n", prog);
}

int main(int argc, char *argv[]) {
  if (argc < 3) {
    print_usage(argv[0]);
    return EXIT_FAILURE;
  }

  if (strcmp(argv[1], "--fan") == 0) {
    uint8_t pattern;
    if (strcmp(argv[2], "on") == 0)
      pattern = 1;
    else if (strcmp(argv[2], "off") == 0)
      pattern = 0;
    else {
      fprintf(stderr, "Invalid fan state '%s'. Use 'on' or 'off'.\n", argv[2]);
      return EXIT_FAILURE;
    }

    int fd = open("/dev/icc", O_RDWR);
    if (fd < 0) {
      perror("Error opening /dev/icc");
      return EXIT_FAILURE;
    }

    if (ioctl(fd, ICC_FAN_CHANGE_SERVO_PATTERN, &pattern) < 0) {
      perror("ioctl");
      close(fd);
      return EXIT_FAILURE;
    }
    printf("Set fan to '%s'\n", argv[2]);
    close(fd);
  } else if (strcmp(argv[1], "--boost") == 0) {
    unsigned long cmd;
    if (strcmp(argv[2], "on") == 0)
      cmd = MP1_BOOST_ENTER;
    else if (strcmp(argv[2], "off") == 0)
      cmd = MP1_BOOST_EXIT;
    else {
      fprintf(stderr, "Invalid boost state '%s'. Use 'on' or 'off'.\n",
              argv[2]);
      return EXIT_FAILURE;
    }

    int fd = open("/dev/mp1", O_RDWR);
    if (fd < 0) {
      perror("Error opening /dev/mp1");
      return EXIT_FAILURE;
    }

    if (ioctl(fd, cmd) < 0) {
      perror("ioctl");
      close(fd);
      return EXIT_FAILURE;
    }
    printf("Set boost to '%s'\n", argv[2]);
    close(fd);
  } else {
    print_usage(argv[0]);
    return EXIT_FAILURE;
  }

  return EXIT_SUCCESS;
}

