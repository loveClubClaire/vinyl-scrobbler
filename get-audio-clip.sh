#!/bin/bash
source /home/pi/ShellCommands/fingerprintingGovernor

if [ "$FINGERPRINT_ENABLED" = true ] ; then
	printf "$(TZ=":US/Eastern" date)" > /home/pi/docs/recording.log
	#Use the arecord function to capture audio from the soundcard and save the audio to audioclip.wav
	#The & at the end of the arecord function is used to run the arecord function on another thread
	arecord -q -D hw:0,0 --buffer-time=2000000 -f cd /home/pi/docs/quietAudioclip.wav &
	#Because arecord is being run on another thread, sleeping our script doesn't halt recording
	sleep 15
	#After recording for 15 seconds, (after a 15 second audio file has been created) kill arecord
	#This needs to be done manually because there is no way to have arecord only run for a set amount of time
	pid=$(pidof arecord)
	kill $pid
	wait $pid
	#killall -KILL arecord > /dev/null 2>&1
	#Run an audio analysis of the resulting sound file and save the results to the output variable
	output=$(sox /home/pi/docs/quietAudioclip.wav -n stat 2>&1)
	echo $output >> /home/pi/docs/recording.log
	#parse the maximum amplitude from the resulting audio analysis
	IFS=$'\n'; read -rd '' -a TEMP <<< "$output"
	IFS=$':'; read -rd '' -a TEMPTWO <<< "${TEMP[4]}"
	#Strip whitespace out of our result and store it in the maxAmplitude variable
	maxAmplitude="$(echo -e "${TEMPTWO[1]}" | tr -d '[:space:]')"
	#Get the absolute value of maxAmplitude
	maxAmplitude=${maxAmplitude#-}
	#Compare our maxAmplitude to 0.001 to see if if's a silent audio file or if music is actually being captured
	#We use the awk command because bash can't do floating point math by default
	#We store the awk result and check that
	varResult=$(awk 'BEGIN{ print "'$maxAmplitude'"<"'0.1'" }')
	if [ "$varResult" -eq 1 ]; then
		#If the audio file is silence, do nothing
		printf "Audio file most likely silence, not sent for audio fingerprinting \n$maxAmplitude\n$(TZ=":US/Eastern" date)" > /home/pi/docs/silence.log
	else
		#If the audio file is actual music...
		echo $maxAmplitude
		printf "$(TZ=":US/Eastern" date)\n"
		#Amplify the audio file by a factor of six (second argument is input file, third is output file)
		#I know it makes the audio clip, I don't need the warnings (-V1)
		sox -V1 -v 5.0 /home/pi/docs/quietAudioclip.wav /home/pi/docs/audioclip.wav
		#Send the audio file to our networked machine to be fingerprinted
		scp -i /home/pi/.ssh/id_rsa /home/pi/docs/audioclip.wav claire@10.0.0.226:/home/claire/AudioFingerprinting/staging
		ssh claire@10.0.0.226 bash /home/claire/AudioFingerprinting/staging/recognizeTrack.sh
		echo -e "-----------------------------------------------\n"
	fi
else
	printf "Audio capture disabled, nothing sent for audio fingerprinting \n$(TZ=":US/Eastern" date)\n" > /home/pi/docs/silence.log
fi
