#!/bin/bash
set -e

DEFAULT_USER=${DEFAULT_USER:-'ubuntu'}
DEFAULT_USER_UID=${USER_UID:-'1000'}
DEFAULT_USER_GID=${USER_GID:-'1000'}
NOPASSWD=${NOPASSWD:-''} # set 'NOPASSWD:' to disable asking sudo password
BUILD_TOOL=${BUILD_TOOL:-'catkin-tools'}
SHELL=${DEFAULT_SHELL:-$SHELL}

# override if $USER env exists
if [[ ! -z "$USER" ]]; then
	DEFAULT_USER=$USER
fi

if [[ $(id -u) -eq 0 ]]; then
	EXEC="exec /sbin/su-exec ${DEFAULT_USER}"

	# if the user does not exist, create user
	if [[ $(id -u ${DEFAULT_USER} 2> /dev/null) != ${DEFAULT_USER_UID} ]]; then
	    echo creating user ${DEFAULT_USER}
		groupadd -g "${DEFAULT_USER_GID}" "${DEFAULT_USER}"
		useradd --create-home --home-dir /home/${DEFAULT_USER} --uid ${DEFAULT_USER_UID} --shell /bin/bash \
		    --gid ${DEFAULT_USER_GID} --groups sudo ${DEFAULT_USER}
		echo "${DEFAULT_USER}:${DEFAULT_USER}" | chpasswd && \
		echo "${DEFAULT_USER} ALL=(ALL) ${NOPASSWD}ALL" >> /etc/sudoers
		touch /home/${DEFAULT_USER}/.sudo_as_admin_successful
	fi

	# mount develop workspace
	if [ -e /ws ]; then
		mkdir -p /home/${DEFAULT_USER}/catkin_ws
		ln -s /ws /home/${DEFAULT_USER}/catkin_ws/src
	fi

	# setup ros environment
	if [[ "$BUILD_TOOL" == "catkin_make" ]]; then
		touch /home/${DEFAULT_USER}/.bash_aliases
		echo "function catkin_make(){(cd ~/catkin_ws && command catkin_make \$@) && source ~/catkin_ws/devel/setup.bash;}" >> /home/${DEFAULT_USER}/.bash_aliases
		mkdir -p /home/${DEFAULT_USER}/catkin_ws/src \
		&& /bin/bash -c ". /opt/ros/noetic/setup.bash; catkin_init_workspace /home/${DEFAULT_USER}/catkin_ws/src" > /dev/null
		echo 'source /opt/ros/noetic/setup.bash' >> /home/${DEFAULT_USER}/.bashrc
	fi
	if [[ "$BUILD_TOOL" == "catkin-tools" ]]; then
		mkdir -p /home/${DEFAULT_USER}/catkin_ws/src \
		&& /bin/bash -c "cd /home/${DEFAULT_USER}/catkin_ws;. /opt/ros/noetic/setup.bash; catkin init" > /dev/null
		echo 'source /opt/ros/noetic/setup.bash' >> /home/${DEFAULT_USER}/.bashrc
		echo 'source `catkin locate --shell-verbs`' >> /home/${DEFAULT_USER}/.bashrc
	fi

	if [ ! -e /home/${DEFAULT_USER}/.config/terminator/config ]; then
		# Avoid org.freedesktop.DBus.Error.Spawn.ExecFailed
		# https://forums.bunsenlabs.org/viewtopic.php?pid=59732#p59732
		mkdir -p /home/${DEFAULT_USER}/.config/terminator
		echo '[global_config]' | tee -a /home/${DEFAULT_USER}/.config/terminator/config > /dev/null
		echo '    dbus = "False"' | tee -a /home/${DEFAULT_USER}/.config/terminator/config > /dev/null
	fi

	chown -R ${DEFAULT_USER}:${DEFAULT_USER} /home/${DEFAULT_USER}

	DEFAULT_USER_UID="$(${EXEC} id -u)"
	DEFAULT_USER_GID="$(${EXEC} id -g)"
	HOME="/home/${DEFAULT_USER}"
else # use existing user
	EXEC="exec"
	DEFAULT_USER="$(whoami)"
	DEFAULT_USER_UID="$(id -u)"
	DEFAULT_USER_GID="$(id -g)"
	if [[ ! -e /home/${DEFAULT_USER}/.bashrc ]]; then
		cp /etc/skel/.* /home/$DEFAULT_USER/
	fi
fi

echo "Launched container with user: ${DEFAULT_USER}, uid: ${DEFAULT_USER_UID}, gid: ${DEFAULT_USER_GID}"

cd ${HOME}

if which "$1" > /dev/null 2>&1 ; then
	${EXEC} "$@"
else
	echo $@ | ${EXEC} ${SHELL} -li
fi
