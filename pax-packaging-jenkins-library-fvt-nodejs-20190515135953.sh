#!/bin/sh -e
set -x

if [ -z "/zaas1" ]; then
  echo "[Pax.pack][ERROR] remoteWorkspace is not set"
  exit 1
fi
if [ -z "pax-packaging-jenkins-library-fvt-nodejs" ]; then
  echo "[Pax.pack][ERROR] job id is not set"
  exit 1
fi

echo "[Pax.pack] working in /zaas1/pax-packaging-jenkins-library-fvt-nodejs-20190515135953 ..."
mkdir -p "/zaas1/pax-packaging-jenkins-library-fvt-nodejs-20190515135953"
cd "/zaas1/pax-packaging-jenkins-library-fvt-nodejs-20190515135953"

# extract tar file
if [ -f "/zaas1/pax-packaging-jenkins-library-fvt-nodejs-20190515135953.tar" ]; then
  echo "[Pax.pack] extracting /zaas1/pax-packaging-jenkins-library-fvt-nodejs-20190515135953.tar to /zaas1/pax-packaging-jenkins-library-fvt-nodejs-20190515135953 ..."
  pax -r -x tar -f "/zaas1/pax-packaging-jenkins-library-fvt-nodejs-20190515135953.tar"
  if [ $? -ne 0 ]; then
    exit 1
  fi
  rm "/zaas1/pax-packaging-jenkins-library-fvt-nodejs-20190515135953.tar"
else
  echo "[Pax.pack][ERROR] tar /zaas1/pax-packaging-jenkins-library-fvt-nodejs-20190515135953.tar file doesn't exist"
  exit 1
fi

# do we have ascii.tar?
if [ -f "/zaas1/pax-packaging-jenkins-library-fvt-nodejs-20190515135953/ascii.tar" ]; then
  echo "[Pax.pack] extracting /zaas1/pax-packaging-jenkins-library-fvt-nodejs-20190515135953/ascii.tar ..."
  cd "/zaas1/pax-packaging-jenkins-library-fvt-nodejs-20190515135953"
  pax -r -x tar -o to=IBM-1047 -f "ascii.tar"
  # copy to target folder
  cp -R ascii/. content
  # remove ascii files
  rm "ascii.tar"
  rm -fr "ascii"
fi

# run pre hook
if [ -f "pre-packaging.sh" ]; then
  echo "[Pax.pack] running pre hook ..."
  cd "/zaas1/pax-packaging-jenkins-library-fvt-nodejs-20190515135953"
  iconv -f ISO8859-1 -t IBM-1047 pre-packaging.sh > pre-packaging.sh.new
  mv pre-packaging.sh.new pre-packaging.sh
  chmod +x pre-packaging.sh
  echo "[Pax.pack] launch:  ./pre-packaging.sh"
   ./pre-packaging.sh
  if [ $? -ne 0 ]; then
    exit 1
  fi
fi

# list working folder
cd /zaas1/pax-packaging-jenkins-library-fvt-nodejs-20190515135953
echo "[Pax.pack] content of /zaas1/pax-packaging-jenkins-library-fvt-nodejs-20190515135953 starts >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
ls -REal
echo "[Pax.pack] content of /zaas1/pax-packaging-jenkins-library-fvt-nodejs-20190515135953 ends   <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"

# create PAX file
if [ -d "/zaas1/pax-packaging-jenkins-library-fvt-nodejs-20190515135953/content" ]; then
  echo "[Pax.pack] creating package ..."
  cd "/zaas1/pax-packaging-jenkins-library-fvt-nodejs-20190515135953/content"
  pax -w -f "/zaas1/pax-packaging-jenkins-library-fvt-nodejs-20190515135953/jenkins-library-fvt-nodejs.pax"  *
  if [ $? -ne 0 ]; then
    exit 1
  fi
  cd "/zaas1/pax-packaging-jenkins-library-fvt-nodejs-20190515135953"
else
  echo "[Pax.pack][ERROR] folder /zaas1/pax-packaging-jenkins-library-fvt-nodejs-20190515135953/content doesn't exist"
  exit 1
fi

# run post hook
if [ -f "post-packaging.sh" ]; then
  echo "[Pax.pack] running post hook ..."
  cd "/zaas1/pax-packaging-jenkins-library-fvt-nodejs-20190515135953"
  iconv -f ISO8859-1 -t IBM-1047 post-packaging.sh > post-packaging.sh.new
  mv post-packaging.sh.new post-packaging.sh
  chmod +x post-packaging.sh
  echo "[Pax.pack] launch:  ./post-packaging.sh"
   ./post-packaging.sh
  if [ $? -ne 0 ]; then
    exit 1
  fi
fi

if [ -f "/zaas1/pax-packaging-jenkins-library-fvt-nodejs-20190515135953/jenkins-library-fvt-nodejs.pax" ]; then
  echo "[Pax.pack] done"
  exit 0
else
  echo "[Pax.pack][ERROR] failed to create PAX file /zaas1/pax-packaging-jenkins-library-fvt-nodejs-20190515135953/jenkins-library-fvt-nodejs.pax, exit."
  exit 1
fi
