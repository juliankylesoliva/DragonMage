using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HintBubble : MonoBehaviour, IInteractable
{
    SpriteRenderer spriteRenderer;
    TextPromptParser textPromptParser;

    [SerializeField] Color selectedColor;
    [SerializeField] bool isTextLow = false;
    [SerializeField] GameObject controlPrompt;

    private PlayerCtrl player;
    private bool isTextShowing = false;
    private bool isUsingKeyboard = true;
    private bool prevIsUsingKeyboard = true;

    void Awake()
    {
        spriteRenderer = this.gameObject.GetComponent<SpriteRenderer>();
        textPromptParser = this.gameObject.GetComponent<TextPromptParser>();
    }

    void Update()
    {
        isUsingKeyboard = (InputHub.playerInput.currentControlScheme == "Keyboard");
        UpdateTextCheck();
        prevIsUsingKeyboard = isUsingKeyboard;
    }

    private void UpdateTextCheck()
    {
        if (isTextShowing && ((isUsingKeyboard && !prevIsUsingKeyboard) || (!isUsingKeyboard && prevIsUsingKeyboard)))
        {
            //string textToSend = hintText;
            //string[] promptListToSend = (isUsingKeyboard ? keyboardPromptsList : gamepadPromptsList);
            ScreenText.SetTextReference(textPromptParser.GetParsedText(), isTextLow, this.gameObject);
        }
    }

    public void Interact(PlayerCtrl playerSrc)
    {
        if (player != null && playerSrc.gameObject.GetInstanceID() == player.gameObject.GetInstanceID())
        {
            if (!isTextShowing)
            {
                isTextShowing = true;
                //string textToSend = hintText;
                //string[] promptListToSend = (isUsingKeyboard ? keyboardPromptsList : gamepadPromptsList);
                ScreenText.SetTextReference(textPromptParser.GetParsedText(), isTextLow, this.gameObject);
                spriteRenderer.color = selectedColor;
                controlPrompt.SetActive(false);
            }
            else
            {
                isTextShowing = false;
                ScreenText.UnsetTextReference(this.gameObject);
                spriteRenderer.color = Color.white;
                controlPrompt.SetActive(true);
            }
        }
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        if (other.gameObject.tag == "Player")
        {
            PlayerCtrl playerTemp = other.gameObject.GetComponent<PlayerCtrl>();
            if (playerTemp != null) { player = playerTemp; }
            player.interaction.SetInteractableRef(this);
            controlPrompt.SetActive(true);
        }
    }

    void OnTriggerExit2D(Collider2D other)
    {
        if (other.gameObject.tag == "Player")
        {
            player.interaction.UnsetInteractableRef(this);
            player = null;
            isTextShowing = false;
            spriteRenderer.color = Color.white;
            ScreenText.UnsetTextReference(this.gameObject);
            controlPrompt.SetActive(false);
        }
    }
}
