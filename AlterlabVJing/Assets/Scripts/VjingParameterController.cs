using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VjingParameterController : MonoBehaviour {

	const string c_factorName = "SFactor";

	KeyCode m_factorUpKey = KeyCode.Z;
	KeyCode m_factorDownKey = KeyCode.S;

	[SerializeField]
	SoundToTexture m_holder = null;

	[SerializeField]
	float m_step = .05f;

	float m_current = .05f;

	private void Update()
	{
		float delta = 0f;
		if (Input.GetKeyDown(m_factorDownKey))
			delta = -m_step;
		else if (Input.GetKeyDown(m_factorUpKey))
			delta = m_step;
		if (delta != 0)
		{
			m_current += delta;
			if(m_holder.m_firstPassMaterial != null)
				m_holder.m_firstPassMaterial.SetFloat(c_factorName, m_current);
			Debug.LogFormat("setting SFactor to {0}", m_current);
		}
	}

}
