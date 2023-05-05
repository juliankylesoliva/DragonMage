using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class ScreenText : MonoBehaviour
{
    [SerializeField] TMP_Text textbox;
    [SerializeField] GameObject backdrop;
    [SerializeField] Vector3 highOffset;
    [SerializeField] Vector3 lowOffset;

    private static string currentText = "";
    private static GameObject currentObjRef = null;
    private static bool isLowOffset = false;

    void Update()
    {
        if (currentObjRef != null)
        {
            textbox.gameObject.SetActive(true);
            backdrop.SetActive(true);
            textbox.text = currentText;
        }
        else
        {
            textbox.gameObject.SetActive(false);
            backdrop.SetActive(false);
            currentText = "";
            isLowOffset = false;
        }
    }

    void LateUpdate()
    {
        this.transform.position = Camera.main.transform.position;
        textbox.transform.localPosition = (isLowOffset ? lowOffset : highOffset);
    }

    public static void SetTextReference(string text, bool low, GameObject go)
    {
        currentText = text;
        isLowOffset = low;
        currentObjRef = go;
    }

    public static void UnsetTextReference(GameObject go)
    {
        if (currentObjRef != null && currentObjRef.GetInstanceID() == go.GetInstanceID())
        {
            currentObjRef = null;
        }
    }
}
