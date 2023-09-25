# maildump-docker
These are Docker files for [ThiefMaster/maildump](https://github.com/ThiefMaster/maildump) - a utility that acts as an SMTP server and "catches" emails, and is itself based on [Samuel Cochran's MailCatcher](https://github.com/sj26/mailcatcher/).

I ***ONLY*** built the Docker images and created the sample files here! All credit for this wonderful and useful tool goes to ThiefMaster.

## Use Cases

If you're developing and you want to test email functionality, this is ideal. I found it pretty useful in my homelab setup and have started to use this when making unit tests for SMTP actions.

If you're homelabbing and don't want to hook up containers or applications to a real email for whatever reason, this still catches activation, password reset, and other emails for you.

The tool runs a basic web interface for you to read and manage the emails, which runs by default on port 1080 (and 8087 in my compose file). If you want to password protect this, you should use an `.htaccess` file and put it together with your nginx configuration.

## Sample docker-compose.yml

I've written this to basically be a copy-paste for homelabbers and testers who already have a compose file for multiple containers.

```
version: '3.9'

services:
  maildump:
    image: jivanyatra/maildump:latest
    container_name: "maildump"
    environment:
      # If you only want the emails in memory, comment out this section
      - DBFILE=1
    volumes:
      # If you only want the emails in memory, comment out this section
      - /path/to/MailDump/temp.db:/data/maildump.db
    ports:
      - 1025:1025 # smtp port
      - 8087:1080 # web interface port
```

The above compose file is fairly self-explanatory.

You can also use this with the db being in memory, ideal for automated testing scenarios. You can use this instead:

```
version: '3.9'

services:
  maildump:
    image: jivanyatra/maildump:latest
    container_name: "maildump"
    ports:
      - 1025:1025 # smtp port
      - 8087:1080 # web interface port
```

To initialize an empty sqlite db, just do:

```sqlite3 maildump.db "VACUUM;"```

or you can use my `temp.db` and rename it to something useful.


## Notes

ThiefMaster's implementation has the ability to save the emails to a database, which you can specify in the docker-compose.yml file optionally. His version also has support for .htaccess password files but I've excluded that functionality for two reasons:

  - If you're using this for local testing via a docker compose or kubernetes, you probably don't need to password protect it.
  - If you're using this on a test server (or using it in a homelab), you're probably running NGINX to proxy containers anyway, and you can just implement the .htaccess support there.
  - I might decide to add it later, if there's any interest.

I've build this off of the very lean alpine python base image. If there's demand for other base images, reach out and I'll figure something out. Also, if you're a Mac user on an M-series chipset and need this, reach out and perhaps we can work together to figure that out.

I don't anticipate ThiefMaster updating the app at this point, but I'll try to keep an eye out and release. No point in setting up CI/CD pipelines for someone else's project when it's not even in active development.

For the build, linux/amd64 was pretty easy/straightforward. There's probably some optimization that can be done, but it's a low enough memory footprint that I don't anticipate issues.

For linux/arm64, things are a bit different. `gevent` and iirc one other dependency need to be compiled from source (no arm64 wheels available), which necessitates installing the build tool packages for alpine, doing the pip install, and then removing the installed build tools. If we don't do this in one `RUN` step in the `Dockerfile`, then the size of the image won't be lean - layers only build and removing data in a later layer doesn't undo the earlier layer.

Admittedly, it's ugly and less than ideal. I suppose I could compile the dependencies in a build image, and then copy it over, and install the wheels... but I feel like we'd be getting deep into a dependency hell for `gevent`, and stepping on others' toes there.

I could also do the compilation/build into a venv and then copy the venv over and add it to a path, but venvs aren't recommended for docker containers and I don't know the reasoning well enough to ignore that.

My approach works, got the job done relatively quickly and easily, and likely doesn't need updating/simplying for the future (because I doubt we'll see significant updates upstream). And, it was a nice small project to get a better understanding of docker multiarch builds and how docker layers images.