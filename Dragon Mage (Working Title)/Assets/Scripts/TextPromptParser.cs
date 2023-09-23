using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class TextPromptParser : MonoBehaviour
{
    [SerializeField] TMP_Text textPromptObj;
    [SerializeField] string[] keyboardPrompts;
    [SerializeField] string[] gamepadPrompts;
    [SerializeField, TextArea(15,10)] string rawTextToDisplay;

    void Update()
    {
        UpdateTextObject();
    }

    void OnEnable()
    {
        UpdateTextObject();
    }

    public string ParseTextPrompt(string rawString, string[] promptArray)
    {
        string retStr = rawString;

        for (int i = 0; i < promptArray.Length; ++i)
        {
            retStr = retStr.Replace($"[{i}]", $"<sprite=\"ControlGuide\" name=\"{promptArray[i]}\">");
        }

        return retStr;
    }

    public string GetParsedText()
    {
        string controlScheme = (InputHub.playerInput != null ? InputHub.playerInput.currentControlScheme : "Keyboard");
        return ParseTextPrompt(rawTextToDisplay, controlScheme != null && controlScheme == "Gamepad" ? gamepadPrompts : keyboardPrompts);
    }

    private void UpdateTextObject()
    {
        if (textPromptObj != null && textPromptObj.gameObject.activeSelf)
        {
            textPromptObj.text = GetParsedText();
        }
    }
}
