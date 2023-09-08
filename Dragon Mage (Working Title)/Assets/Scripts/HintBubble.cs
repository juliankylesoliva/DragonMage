using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class HintBubble : MonoBehaviour, IInteractable
{
    SpriteRenderer spriteRenderer;

    [SerializeField] Color selectedColor;
    [SerializeField] bool isTextLow = false;
    [SerializeField] bool enableDragonText = false;
    [SerializeField] TMP_Text controlPrompt;
    [SerializeField] string keyboardInteractPrompt = "Keyboard_V";
    [SerializeField] string gamepadInteractPrompt = "Gamepad_EFB";
    [SerializeField] string[] keyboardPromptsList;
    [SerializeField] string[] gamepadPromptsList;
    [SerializeField, TextArea(15,20)] string hintText = "TEST1";
    [SerializeField, TextArea(15, 20)] string dragonText = "UNUSED";

    private PlayerCtrl player;
    private bool isTextShowing = false;
    private bool isUsingKeyboard = true;
    private bool prevIsUsingKeyboard = true;

    void Awake()
    {
        spriteRenderer = this.gameObject.GetComponent<SpriteRenderer>();
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
            bool isADragon = (player.form.currentMode == CharacterMode.DRAGON);
            string textToSend = (enableDragonText && isADragon ? dragonText : hintText);
            string[] promptListToSend = (isUsingKeyboard ? keyboardPromptsList : gamepadPromptsList);
            ScreenText.SetTextReference(TextPromptParser.ParseTextPrompt(textToSend, promptListToSend), isTextLow, this.gameObject);
        }

        if (controlPrompt.gameObject.activeSelf) { controlPrompt.text = $"<sprite=\"ControlGuide\" name=\"{(isUsingKeyboard ? keyboardInteractPrompt : gamepadInteractPrompt)}\">"; }
    }

    public void Interact(PlayerCtrl playerSrc)
    {
        if (player != null && playerSrc.gameObject.GetInstanceID() == player.gameObject.GetInstanceID())
        {
            if (!isTextShowing)
            {
                isTextShowing = true;
                bool isADragon = (player.form.currentMode == CharacterMode.DRAGON);
                string textToSend = (enableDragonText && isADragon ? dragonText : hintText);
                string[] promptListToSend = (isUsingKeyboard ? keyboardPromptsList : gamepadPromptsList);
                ScreenText.SetTextReference(TextPromptParser.ParseTextPrompt(textToSend, promptListToSend), isTextLow, this.gameObject);
                spriteRenderer.color = selectedColor;
                controlPrompt.gameObject.SetActive(false);
            }
            else
            {
                isTextShowing = false;
                ScreenText.UnsetTextReference(this.gameObject);
                spriteRenderer.color = Color.white;
                controlPrompt.gameObject.SetActive(true);
                controlPrompt.text = $"<sprite=\"ControlGuide\" name=\"{(isUsingKeyboard ? keyboardInteractPrompt : gamepadInteractPrompt)}\">";
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
            controlPrompt.gameObject.SetActive(true);
            controlPrompt.text = $"<sprite=\"ControlGuide\" name=\"{(isUsingKeyboard ? keyboardInteractPrompt : gamepadInteractPrompt)}\">";
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
            controlPrompt.gameObject.SetActive(false);
        }
    }
}
