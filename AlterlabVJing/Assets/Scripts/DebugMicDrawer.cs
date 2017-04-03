using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DebugMicDrawer : MonoBehaviour {
	public MicGrabber micGrabber = null;

	private void Update()
	{
		var data = micGrabber.m_extractedData;

		var step = 1f / data.Length;

		Vector3 currentPos = new Vector3(-3.5f, 0f, 0f);
		for (int i = 1; i < data.Length; ++i)
		{
			var pos = new Vector3(i * 7f * step - 3.5f, data[i], 0);
			Debug.DrawLine(currentPos, pos, Color.yellow);
			currentPos = pos;
		}
	}
}
