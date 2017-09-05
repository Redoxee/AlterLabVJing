using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class QuadToCameraResizer : MonoBehaviour {
	public Camera m_camera;

	private void Awake()
	{
		float ratio = (float)Screen.height / (float)Screen.width;
		var height = m_camera.orthographicSize * 2;
		transform.localScale = new Vector3(height / ratio, height, 1);

        Material mat = GetComponent<Renderer>().material;
	}
}
