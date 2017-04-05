using System;
using System.Collections.Generic;
using UnityEngine;

public class DebugMicDrawer : MonoBehaviour {
	public MicGrabber micGrabber = null;

	float m_recordedMax = -1000f;

	private void Update()
	{
		var data = micGrabber.m_extractedData;

		//double[] doubleData = Array.ConvertAll(data, x => (double)x);
		//m_fft.FFT(doubleData, true);
		//data = Array.ConvertAll(doubleData, x => (float)x);

		var step = 1f / data.Length;

		Vector3 currentPos = new Vector3(-3.5f, 0f, 0f);
		for (int i = 1; i < data.Length; ++i)
		{
			var pos = new Vector3(i * 7f * step - 3.5f, data[i], 0);
			Debug.DrawLine(currentPos, pos, Color.yellow);
			currentPos = pos;
			m_recordedMax = Mathf.Max(data[i], m_recordedMax);
		}

		if(Time.frameCount % 60 == 0)
			Debug.LogFormat("Recorded Max : {0}", m_recordedMax);
	}
}
