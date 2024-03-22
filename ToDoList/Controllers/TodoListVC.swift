import UIKit
import RealmSwift
import ChameleonFramework

class TodoListVC: UITableViewController{
    
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var addItemButton: UIBarButtonItem!
    
    let realm = try! Realm()
    
    var todoItems:Results<Item>?
    
    var selectedCategory:Category? {
        //Runs When a variable gets a new value
        didSet{
            loadItems()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.delegate=self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let safeHex=selectedCategory?.colorOfCell{
            
            let contrastColour=ContrastColorOf(UIColor(hexString: safeHex)!, returnFlat: true)
            let regularColor=UIColor(hexString: safeHex)
            
            title=selectedCategory!.title
            guard let navBar=navigationController?.navigationBar else{fatalError("Navigation controller doesn't exist!")}
             
            navBar.backgroundColor=regularColor
            searchBar.barTintColor=regularColor
            searchBar.searchTextField.backgroundColor = .systemBackground
            
            navBar.largeTitleTextAttributes=[NSAttributedString.Key.foregroundColor: contrastColour]
            navBar.tintColor=contrastColour
            addItemButton.tintColor=contrastColour
            
            
        }
    }
    
    @IBAction func AddButtonPressed(_ sender: UIBarButtonItem) {
        
        var textResult = UITextField()
        
        let alert=UIAlertController(title: "Add New Todo Item", message: "", preferredStyle: .alert )
        
        let action=UIAlertAction(title: "Add Item", style: .default) { action in
            
            //what happens when the user clicks add item
            if textResult.text==""{
                let alert=UIAlertController(title: "Warning", message: "No Items Were Added", preferredStyle: .alert)
                let action=UIAlertAction(title: "Ok", style: .default)
                alert.addAction(action)
                self.present(alert, animated: true)
            }else{
                
//              stores added item in the array todoItems
                if let safeSelectedCategory=self.selectedCategory{
                    do{
                        //Making and Saving new item under it's parent category
                        try self.realm.write {
                            let newItem = Item()
                            newItem.name = textResult.text!
                            newItem.dateCreated=Date()
                            safeSelectedCategory.items.append(newItem)
                        }
                    }catch{
                        print("Error saving items \(error)")
                    }
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addAction(action)
        alert.addTextField { alertTextField in
            alertTextField.placeholder="Create New Item"
            textResult=alertTextField
        }
        present(alert, animated: true)
    }
}

//MARK: - UITableViewDataSources
extension TodoListVC{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell=tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell")!
        let cell=UITableViewCell(style: .default , reuseIdentifier: "ToDoItemCell")
        
        //Populate the cell with it's name and Done attributes
        if let itemList = todoItems?[indexPath.row]{
            cell.textLabel?.text=itemList.name
            
            cell.accessoryType = itemList.done ? .checkmark : .none
        
            cell.tintColor=UIColor.white
            
            if let safeColour=UIColor(hexString: selectedCategory!.colorOfCell!)?.darken(byPercentage:CGFloat(indexPath.row)/CGFloat(todoItems!.count)){
                cell.backgroundColor = safeColour
                cell.textLabel?.textColor = ContrastColorOf(safeColour, returnFlat: true)
            }
            
        }else{
            cell.textLabel?.text="No Items Added yet"
        }
        
        return cell
        
    }
    
}

//MARK: - UITableViewDelegate
extension TodoListVC{
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Update items
        if let item=todoItems?[indexPath.row]{
            do{
                try realm.write {
                    item.done = !item.done
                }
            }catch{
                print("Error updating the TableView Cell\(error)")
            }
        }
        self.tableView.reloadData()
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //Swipe to delete category
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if let safeTodoItemsArray=todoItems?[indexPath.row]{
                do{
                    try realm.write {
                        realm.delete(safeTodoItemsArray)
                    }
                }catch{
                    print("Couldn't delete Item: \(error)")
                }
            }
        }
        self.tableView.reloadData()
    }
}


//MARK: - Model manipulation methods
extension TodoListVC{
    
    
    func loadItems(){
        
        //Adds the items from the specified category to the todoItems Array
        todoItems=selectedCategory?.items.sorted(byKeyPath: "name", ascending: false)
        
        tableView.reloadData()
    }
}

//MARK: - UISearchBarDelegate
extension TodoListVC:UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        print("Search bar")
        todoItems=todoItems?
            .filter("name CONTAINS[cd] %@", searchBar.text!)
            .sorted(byKeyPath: "dateCreated", ascending: true) 
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count==0{
            loadItems()
            print("Search bar")
            //Tells the search bar to go to the background and make the keyboard dissappears
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

