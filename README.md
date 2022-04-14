# Chris's Local Disco Diffusion CoLab Image

> There are many like this, but this one is mine. And it can be yours too!

This repo should help you to get Disco Diffusion (and with some tinkering, other CoLab notebooks) running on your local machine in a safe and repeatable fashion. This Readme will explain why you might want to do this, how to know if you can do this, and how to do this. But first:

### DISCLAIMER

I (Chris) can't promise that I'll keep this repo up to date. I definitely can't help if you run into error messages that come from Jupyter, the notebook you're using, or any of the tools or libraries. If you run into an issue and have a fix, feel free to make a PR. I can't promise I'll be able to review and merge it, but if it's a small/simple change I'll try.

With all that said, I basically cobbled this together from a [Dockerfile that was a couple years old](https://github.com/sorokine/docker-colab-local/blob/master/Dockerfile), so I even if I can't keep this up to date, it hopefully won't be too much work to get going.

OK, boring stuff out of the way, let's go:

## Why should I host CoLab locally via Docker?

For me, it came down to:

- **Security** - I don't want to give Google Drive access to any random CoLab notebook I find on the web, so for me, saving outputs is cumbersome. Also, I don't want to run CoLab locally on my bare OS. I can't think of a better way to spread a crypto miner than by sticking it in a huge, complicated notebook with a ton of hype around it. I'm sure most of the people in this community are trustworthy people, but this still feels dangerous. Docker helps prevent many vectors an attacker could theoretically use.
- **Stability** - I was having issues with my CoLab Runtimes disconnecting if I was away from the keyboard for a few hours. This was annoying, and I didn't want to pay for CoLab Pro when my [RTX 2080 Ti](https://www.techpowerup.com/gpu-specs/geforce-rtx-2080-ti.c3305) approximately matches most of the specs of a [Tesla T4](https://www.techpowerup.com/gpu-specs/tesla-t4.c3316) (though with a little less VRAM).

## Can I (me, the person reading this) host CoLab locally via Docker?

Yes, if:

- Your computer is running Linux, or you have Windows with WSL2 (WSL1 will not work).
- You have a recent Nvidia GPU. Check [a GPU spec site](https://www.techpowerup.com/gpu-specs/) to see how your GPU compares to the ones Google uses for CoLab Runtimes. As I mentioned above, my RTX 2080 Ti approximately matches the Tesla T4 used in many CoLab Runtimes. If you have an RTX 3070 or higher you should be good. If you have less than 10GB of VRAM you'll have a really hard time with notebooks like Disco Diffusion (server GPUs generally have way more VRAM than gaming GPUs).

## How do I do this?

- Start by making sure you're using the [latest Nvidia drivers](https://www.nvidia.com/download/index.aspx). Update and reboot if you aren't.
- Install all the dependencies:
  - For Windows, follow [these instructions](https://docs.nvidia.com/cuda/wsl-user-guide/index.html) to get WSL2, CUDA, Docker and the Nvidia Container Toolkit.
  - For Linux, follow [these instructions](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html) to get CUDA, Docker and the Nvidia Container Toolkit.
- Come up with a password, and use `export JUPYTER_PASSWORD_FOR_COLAB='whateverthepasswordis'` to set it. You'll need to do this any time you open a new terminal window.

At this point you're all set to build the Docker image. Note that I've written this Docker file to download the libraries and models that Disco Diffusion uses, and that if you're using a different notebook you should comment out those sections, as they download some very large models. Building the image takes about 20-25 minutes on my i7 8700K, so budget some time the first time you run this. But after you've built the image once, the whole thing should start instantly.

To build the image (if it hasn't been built) and then start the container with Jupyter/CoLab running, run `./run.sh`.

You should see something like this:

```
[I 19:14:39.107 NotebookApp] Serving notebooks from local directory: /opt/colab
[I 19:14:39.107 NotebookApp] 0 active kernels
[I 19:14:39.107 NotebookApp] The Jupyter Notebook is running at:
[I 19:14:39.107 NotebookApp] http://0.0.0.0:8081/?token=...
[I 19:14:39.107 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
```

In CoLab, click the arrow next to "Connect" and choose "Connect to a local runtime". Paste the following URL with your password as the token: http://localhost:8081/?token=whateveryourpasswordis You should now be able to run your CoLab notebook against your local machine.

## Common issues

- Issues with connecting from CoLab in the browser: Make sure you're connecting to http://localhost:8081/?token=whateveryourtokenis and not https:// or 0.0.0.0, as those will not work. Also, if you're using WSL2, double check that you can start a basic webserver on a port and serve files, as sometimes WSL has its ports blocked (if you Google around you can find some workarounds).
- Error messages saying Docker isn't running: If you installed Docker correctly, there's still a chance that it doesn't boot when your system boots. Try running `sudo service docker start` and then try running ./run.sh again.
- Errors in the notebook: Sadly you're on your own here.