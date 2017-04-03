using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;

public class MicGrabber : MonoBehaviour {

	//Written in part by Benjamin Outram

	//option to toggle the microphone listenter on startup or not
	public bool m_startMicOnStartup = true;

	//allows start and stop of listener at run time within the unity editor
	public bool m_stopMicrophoneListener = false;
	public bool m_startMicrophoneListener = false;

	private bool m_microphoneListenerOn = false;

	//public to allow temporary listening over the speakers if you want of the mic output
	//but internally it toggles the output sound to the speakers of the audiosource depending
	//on if the microphone listener is on or off
	public bool m_disableOutputSound = false; 
 
     //an audio source also attached to the same object as this script is
     AudioSource m_audioSource;

	//make an audio mixer from the "create" menu, then drag it into the public field on this script.
	//double click the audio mixer and next to the "groups" section, click the "+" icon to add a 
	//child to the master group, rename it to "microphone".  Then in the audio source, in the "output" option, 
	//select this child of the master you have just created.
	//go back to the audiomixer inspector window, and click the "microphone" you just created, then in the 
	//inspector window, right click "Volume" and select "Expose Volume (of Microphone)" to script,
	//then back in the audiomixer window, in the corner click "Exposed Parameters", click on the "MyExposedParameter"
	//and rename it to "Volume"
	public AudioMixer m_masterMixer;


	float m_timeSinceRestart = 0;

	[NonSerialized]
	public float[] m_extractedData = new float[1024];

	void Start()
	{
		//start the microphone listener
		if (m_startMicOnStartup)
		{
			RestartMicrophoneListener();
			StartMicrophoneListener();
		}
	}

	void Update()
	{

		//can use these variables that appear in the inspector, or can call the public functions directly from other scripts
		if (m_stopMicrophoneListener)
		{
			StopMicrophoneListener();
		}
		if (m_startMicrophoneListener)
		{
			StartMicrophoneListener();
		}
		//reset paramters to false because only want to execute once
		m_stopMicrophoneListener = false;
		m_startMicrophoneListener = false;

		//must run in update otherwise it doesnt seem to work
		MicrophoneIntoAudioSource(m_microphoneListenerOn);

		//can choose to unmute sound from inspector if desired
		DisableSound(!m_disableOutputSound);
		m_audioSource.GetOutputData(m_extractedData,0);

		//float acc = 0;
		//for (int i = 0; i < m_extractedData.Length; i++)
		//	acc += m_extractedData[i];

		//if (acc > 1)
		//Debug.Log(acc);
	}


	//stops everything and returns audioclip to null
	public void StopMicrophoneListener()
	{
		//stop the microphone listener
		m_microphoneListenerOn = false;
		//reenable the master sound in mixer
		m_disableOutputSound = false;
		//remove mic from audiosource clip
		m_audioSource.Stop();
		m_audioSource.clip = null;

		Microphone.End(null);
	}


	public void StartMicrophoneListener()
	{
		//start the microphone listener
		m_microphoneListenerOn = true;
		//disable sound output (dont want to hear mic input on the output!)
		m_disableOutputSound = true;
		//reset the audiosource
		RestartMicrophoneListener();
	}


	//controls whether the volume is on or off, use "off" for mic input (dont want to hear your own voice input!) 
	//and "on" for music input
	public void DisableSound(bool SoundOn)
	{

		float volume = 0;

		if (SoundOn)
		{
			volume = 0.0f;
		}
		else
		{
			volume = -80.0f;
		}

		m_masterMixer.SetFloat("MasterVolume", volume);
	}



	// restart microphone removes the clip from the audiosource
	public void RestartMicrophoneListener()
	{

		m_audioSource = GetComponent<AudioSource>();

		//remove any soundfile in the audiosource
		m_audioSource.clip = null;

		m_timeSinceRestart = Time.time;

	}

	//puts the mic into the audiosource
	void MicrophoneIntoAudioSource(bool MicrophoneListenerOn)
	{

		if (MicrophoneListenerOn)
		{
			//pause a little before setting clip to avoid lag and bugginess
			if (Time.time - m_timeSinceRestart > 0.5f && !Microphone.IsRecording(null))
			{
				m_audioSource.clip = Microphone.Start(null, true, 2, 44100);

				//wait until microphone position is found (?)
				while (!(Microphone.GetPosition(null) > 0))
				{
				}

				m_audioSource.Play(); // Play the audio source
			}
		}
	}
}
