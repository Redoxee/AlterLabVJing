using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BGManager : MonoBehaviour {

	[SerializeField]
	List<Texture2D> m_texureToDisplay = null;

	[SerializeField]
	GameObject m_bgPrefab = null;

	List<BGAlphaController> m_controllerList = new List<BGAlphaController>();

	int m_currentDisplay = 0;

	private void Start()
	{

		for (int i = 0; i < m_texureToDisplay.Count;++i)
		{
			var tex = m_texureToDisplay[i];
			var bg = Instantiate(m_bgPrefab);
			bg.transform.SetParent(this.transform, true);
			bg.transform.localPosition = Vector3.zero + new Vector3(0, 0, i);
			var controller = bg.GetComponent<BGAlphaController>();
			m_controllerList.Add(controller);
			controller.SetTexture(tex);
		}

		SetDisplay(m_currentDisplay);
	}

	void SetDisplay(int display = 0, bool force = false)
	{
		for (int i = 0; i < m_controllerList.Count; ++i)
		{
			m_controllerList[i].SetDisplay(i == display);
		}
	}

	void Update()
	{
		bool hasChanged = false;
		if (Input.GetKeyDown(KeyCode.LeftArrow))
		{
			m_currentDisplay -= 1;
			hasChanged = true;
		}
		else if (Input.GetKeyDown(KeyCode.RightArrow))
		{
			m_currentDisplay += 1;
			hasChanged = true;
		}

		if (m_currentDisplay < 0)
			m_currentDisplay = 0;
		if (m_currentDisplay >= m_controllerList.Count)
			m_currentDisplay = m_controllerList.Count - 1;

		if (hasChanged)
		{
			SetDisplay(m_currentDisplay);
		}
	}

}
